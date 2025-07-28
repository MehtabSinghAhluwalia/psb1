import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';
import '../models/app_state.dart';
import '../utils/tool_integration_template.dart';
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:finwise_app/providers/language_provider.dart';
import 'package:http/http.dart' as http;

// Add this mock AI/ML function at the top of the file (after imports):
Future<double> fetchPredictedInflation(int yearsToRetirement) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:5000/predict_inflation'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'years_to_retirement': yearsToRetirement}),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // FIX: Use the correct key
    return (data['inflation_rate'] as num).toDouble();
  } else {
    throw Exception('Failed to fetch inflation rate');
  }
}

Future<String> _translateText(String text, String targetLang) async {
  const backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://127.0.0.1:5001');
  final url = Uri.parse('$backendUrl/translate');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'text': text, 'target_lang': targetLang}),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['translated_text'] ?? text;
  } else {
    return text;
  }
}

class RetirementPlannerScreen extends StatefulWidget {
  const RetirementPlannerScreen({super.key});

  @override
  State<RetirementPlannerScreen> createState() => _RetirementPlannerScreenState();
}

class _RetirementPlannerScreenState extends State<RetirementPlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentAgeController = TextEditingController();
  final _retirementAgeController = TextEditingController();
  final _currentSavingsController = TextEditingController();
  final _expectedExpensesController = TextEditingController();
  final _inflationRateController = TextEditingController();
  Map<String, dynamic>? _recommendations;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFormWithExistingData();
    });
    _currentAgeController.addListener(_updateInflationRate);
    _retirementAgeController.addListener(_updateInflationRate);
  }

  // Replace _updateInflationRate with async API call:
  void _updateInflationRate() async {
    final currentAge = int.tryParse(_currentAgeController.text) ?? 0;
    final retirementAge = int.tryParse(_retirementAgeController.text) ?? 0;
    final yearsToRetirement = (retirementAge - currentAge).clamp(0, 100);
    _inflationRateController.text = '...'; // Show loading
    try {
      final predicted = await fetchPredictedInflation(yearsToRetirement);
      setState(() {
        _inflationRateController.text = predicted.toStringAsFixed(1);
      });
    } catch (e) {
      setState(() {
        _inflationRateController.text = '6.0'; // fallback
      });
    }
  }

  void _prefillFormWithExistingData() {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Pre-fill with existing retirement plan data if available
    if (appState.retirementPlan != null) {
      _currentAgeController.text = appState.retirementPlan!.currentAge.toString();
      _retirementAgeController.text = appState.retirementPlan!.retirementAge.toString();
      _currentSavingsController.text = appState.retirementPlan!.currentSavings.toString();
      _expectedExpensesController.text = appState.retirementPlan!.expectedExpenses.toString();
      // Set inflation rate using AI/ML prediction
      _updateInflationRate();
    }
  }

  void _saveRetirementPlan() {
    if (_formKey.currentState!.validate()) {
      final currentAge = int.parse(_currentAgeController.text);
      final retirementAge = int.parse(_retirementAgeController.text);
      final currentSavings = double.parse(_currentSavingsController.text);
      final expectedExpenses = double.parse(_expectedExpensesController.text);
      final inflationRate = double.parse(_inflationRateController.text);

      // Generate recommendations and analysis using AppState data
      _generateRecommendations(currentAge, retirementAge, currentSavings, expectedExpenses, inflationRate);

      Provider.of<AppState>(context, listen: false).setRetirementPlan(
        RetirementPlan(
          currentAge: currentAge,
          retirementAge: retirementAge,
          currentSavings: currentSavings,
          expectedExpenses: expectedExpenses,
          inflationRate: inflationRate,
        ),
      );

      // Log interaction for ML/AI training
      _logInteraction(currentAge, retirementAge, currentSavings, expectedExpenses, inflationRate);

      setState(() {});
    }
  }

  Future<void> _generateRecommendations(int currentAge, int retirementAge, double currentSavings, double expectedExpenses, double inflationRate) async {
    final appState = Provider.of<AppState>(context, listen: false);
    List<String> recommendations = [];
    List<String> warnings = [];
    List<String> insights = [];

    // Calculate retirement corpus requirements
    int yearsToRetirement = retirementAge - currentAge;
    double inflatedMonthlyExpenses = expectedExpenses * pow(1 + inflationRate / 100, yearsToRetirement);
    double annualExpenses = inflatedMonthlyExpenses * 12;
    double requiredCorpus = annualExpenses * 25; // 25x annual expenses rule
    double corpusGap = requiredCorpus - currentSavings;

    // Retirement timeline analysis
    if (yearsToRetirement < 10) {
      warnings.add('⚠️ Only ${yearsToRetirement} years to retirement - consider aggressive savings or extending retirement age');
    } else if (yearsToRetirement > 30) {
      insights.add('💡 ${yearsToRetirement} years to retirement - good time for long-term planning');
    } else {
      recommendations.add('✅ ${yearsToRetirement} years to retirement - balanced timeline for planning');
    }

    // Corpus adequacy analysis
    double corpusCoverage = (currentSavings / requiredCorpus) * 100;
    if (corpusCoverage > 100) {
      recommendations.add('🎉 Excellent! Your current savings exceed the required corpus by ${_currencyFormat.format(currentSavings - requiredCorpus)}');
    } else if (corpusCoverage > 50) {
      insights.add('💪 Good progress! You have ${corpusCoverage.toStringAsFixed(1)}% of required corpus');
    } else {
      warnings.add('⚠️ You need ${_currencyFormat.format(corpusGap)} more to meet retirement corpus requirements');
    }

    // Monthly savings requirement
    if (yearsToRetirement > 0) {
      double monthlySavingsNeeded = corpusGap / (yearsToRetirement * 12);
      if (appState.taxProfile != null) {
        double monthlyIncome = appState.taxProfile!.income / 12;
        double savingsToIncomeRatio = (monthlySavingsNeeded / monthlyIncome) * 100;
        
        if (savingsToIncomeRatio > 40) {
          warnings.add('⚠️ Required monthly savings (${savingsToIncomeRatio.toStringAsFixed(1)}% of income) is very high');
        } else if (savingsToIncomeRatio > 20) {
          insights.add('💡 Required monthly savings: ${savingsToIncomeRatio.toStringAsFixed(1)}% of income');
        } else {
          recommendations.add('✅ Required monthly savings (${savingsToIncomeRatio.toStringAsFixed(1)}% of income) is manageable');
        }
      }
    }

    // Investment analysis
    if (appState.investments.isNotEmpty) {
      double totalInvestments = appState.investments.map((i) => i.amount).reduce((a, b) => a + b);
      double avgInvestmentReturn = appState.investments.map((i) => i.expectedReturn).reduce((a, b) => a + b) / appState.investments.length;
      
      if (avgInvestmentReturn > inflationRate + 5) {
        recommendations.add('✅ Your investments (${avgInvestmentReturn.toStringAsFixed(1)}% return) are beating inflation (${inflationRate.toStringAsFixed(1)}%)');
      } else {
        warnings.add('⚠️ Investment returns (${avgInvestmentReturn.toStringAsFixed(1)}%) barely cover inflation (${inflationRate.toStringAsFixed(1)}%)');
      }

      double investmentToCorpusRatio = (totalInvestments / requiredCorpus) * 100;
      if (investmentToCorpusRatio > 50) {
        recommendations.add('✅ Your investments contribute significantly to retirement corpus');
      } else {
        insights.add('💡 Consider increasing retirement-focused investments');
      }
    }

    // Goal vs Retirement balance
    if (appState.goals.isNotEmpty) {
      double totalGoalAmount = appState.goals.map((g) => g.targetAmount - g.currentAmount).reduce((a, b) => a + b);
      double totalFinancialNeeds = totalGoalAmount + corpusGap;
      
      if (appState.taxProfile != null) {
        double monthlyIncome = appState.taxProfile!.income / 12;
        double monthlyNeeds = totalFinancialNeeds / (yearsToRetirement * 12);
        double needsToIncomeRatio = (monthlyNeeds / monthlyIncome) * 100;
        
        if (needsToIncomeRatio > 60) {
          warnings.add('⚠️ Combined financial needs (${needsToIncomeRatio.toStringAsFixed(1)}% of income) may be unrealistic');
        } else {
          insights.add('💡 Combined financial needs: ${needsToIncomeRatio.toStringAsFixed(1)}% of monthly income');
        }
      }
    }

    // EMI impact on retirement
    if (appState.loans.isNotEmpty) {
      double totalEMI = appState.loans.map((l) => l.emiAmount).reduce((a, b) => a + b);
      if (appState.taxProfile != null) {
        double monthlyIncome = appState.taxProfile!.income / 12;
        double emiToIncomeRatio = (totalEMI / monthlyIncome) * 100;
        
        if (emiToIncomeRatio > 30) {
          warnings.add('⚠️ High EMI commitments (${emiToIncomeRatio.toStringAsFixed(1)}% of income) may impact retirement savings');
        } else {
          insights.add('💡 EMI commitments are manageable for retirement planning');
        }
      }
    }

    // Inflation sensitivity
    if (inflationRate > 8) {
      warnings.add('⚠️ High inflation assumption (${inflationRate.toStringAsFixed(1)}%) may require higher corpus');
    } else if (inflationRate < 4) {
      insights.add('💡 Conservative inflation assumption (${inflationRate.toStringAsFixed(1)}%) - corpus may be adequate');
    }

    // Age-based recommendations
    if (currentAge < 30) {
      recommendations.add('✅ Early start to retirement planning - compound interest is your friend!');
    } else if (currentAge > 50) {
      warnings.add('⚠️ Late start to retirement planning - consider aggressive savings or extending retirement age');
    }

    // Multilingual translation logic
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale.languageCode;
    if (lang != 'en') {
      recommendations = await Future.wait(recommendations.map((r) async => await _translateText(r, lang)));
      warnings = await Future.wait(warnings.map((w) async => await _translateText(w, lang)));
      insights = await Future.wait(insights.map((i) async => await _translateText(i, lang)));
    }
    setState(() {
      _recommendations = {
        'recommendations': recommendations,
        'warnings': warnings,
        'insights': insights,
        'yearsToRetirement': yearsToRetirement,
        'requiredCorpus': requiredCorpus,
        'corpusGap': corpusGap,
        'corpusCoverage': corpusCoverage,
        'inflatedMonthlyExpenses': inflatedMonthlyExpenses,
      };
    });
  }

  void _logInteraction(int currentAge, int retirementAge, double currentSavings, 
      double expectedExpenses, double inflationRate) {
    final appState = Provider.of<AppState>(context, listen: false);
    final financialSnapshot = appState.getUserFinancialSnapshot();
    
    int yearsToRetirement = retirementAge - currentAge;
    double inflatedMonthlyExpenses = expectedExpenses * pow(1 + inflationRate / 100, yearsToRetirement);
    double requiredCorpus = inflatedMonthlyExpenses * 12 * 25;
    
    final interactionLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'tool': 'retirement_planner',
      'action': 'save_retirement_plan',
      'input': {
        'currentAge': currentAge,
        'retirementAge': retirementAge,
        'currentSavings': currentSavings,
        'expectedExpenses': expectedExpenses,
        'inflationRate': inflationRate,
      },
      'output': {
        'yearsToRetirement': yearsToRetirement,
        'requiredCorpus': requiredCorpus,
        'corpusGap': requiredCorpus - currentSavings,
        'corpusCoverage': (currentSavings / requiredCorpus) * 100,
      },
      'userFinancialSnapshot': financialSnapshot,
      'recommendations': _recommendations,
    };

    print('ML/AI Training Data: ${jsonEncode(interactionLog)}');
  }

  @override
  void dispose() {
    _currentAgeController.dispose();
    _retirementAgeController.dispose();
    _currentSavingsController.dispose();
    _expectedExpensesController.dispose();
    _inflationRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final retirementPlan = appState.retirementPlan;
    
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: 'Retirement Planner',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Financial Overview Card
            ToolIntegrationTemplate.buildFinancialOverviewCard(context),
            const SizedBox(height: 16),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _currentAgeController,
                    decoration: const InputDecoration(
                      labelText: 'Current Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current age';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _retirementAgeController,
                    decoration: const InputDecoration(
                      labelText: 'Retirement Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your retirement age';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _currentSavingsController,
                    decoration: const InputDecoration(
                      labelText: 'Current Savings',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current savings';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _expectedExpensesController,
                    decoration: const InputDecoration(
                      labelText: 'Expected Monthly Expenses (at retirement)',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expected expenses';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _inflationRateController,
                    decoration: const InputDecoration(
                      labelText: 'Expected Inflation Rate (%)',
                      suffixText: '%',
                      border: OutlineInputBorder(),
                      helperText: 'Estimated by AI based on your retirement timeline',
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveRetirementPlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Save Retirement Plan & Get Analysis',
                      style: TextStyle(fontSize: 16, color: Colors.white),
      ),
                  ),
                ],
              ),
            ),

            // Recommendations Section
            if (_recommendations != null) ...[
              const SizedBox(height: 24),
              ToolIntegrationTemplate.buildRecommendationsCard(context, _recommendations!),
            ],

            const SizedBox(height: 24),
            if (retirementPlan != null) ...[
              Text('Your Retirement Plan:', style: Theme.of(context).textTheme.titleMedium),
              ListTile(
                title: Text('Current Age: ${retirementPlan.currentAge}'),
                subtitle: Text('Retirement Age: ${retirementPlan.retirementAge}'),
                trailing: Text('Inflation: ${retirementPlan.inflationRate}%'),
              ),
              ListTile(
                title: Text('Current Savings: ${_currencyFormat.format(retirementPlan.currentSavings)}'),
                subtitle: Text('Expected Expenses: ${_currencyFormat.format(retirementPlan.expectedExpenses)}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 