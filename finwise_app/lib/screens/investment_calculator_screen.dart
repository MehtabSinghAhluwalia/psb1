import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/app_state.dart';
import '../utils/tool_integration_template.dart';
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:finwise_app/providers/language_provider.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';
import 'package:http/http.dart' as http;

class InvestmentCalculatorScreen extends StatefulWidget {
  const InvestmentCalculatorScreen({super.key});

  @override
  State<InvestmentCalculatorScreen> createState() => _InvestmentCalculatorScreenState();
}

class _InvestmentCalculatorScreenState extends State<InvestmentCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _expectedReturnController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  String _investmentType = 'SIP';
  String _riskProfile = 'Moderate';
  Map<String, dynamic>? _recommendations;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFormWithExistingData();
    });
  }

  void _prefillFormWithExistingData() {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Pre-fill with existing investment data if available
    if (appState.investments.isNotEmpty) {
      final lastInvestment = appState.investments.last;
      _amountController.text = lastInvestment.amount.toString();
      _expectedReturnController.text = lastInvestment.expectedReturn.toString();
      _investmentType = lastInvestment.type;
      _riskProfile = lastInvestment.riskProfile;
    }
  }

  void _addInvestment() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final expectedReturn = double.parse(_expectedReturnController.text);
      final startDate = DateTime.now();
      final endDate = DateTime.now().add(const Duration(days: 365 * 5));

      // Generate recommendations and analysis using AppState data
      _generateRecommendations(amount, expectedReturn);

      Provider.of<AppState>(context, listen: false).addInvestment(
        Investment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: _investmentType,
          amount: amount,
          expectedReturn: expectedReturn,
          riskProfile: _riskProfile,
          startDate: startDate,
          endDate: endDate,
        ),
      );

      // Log interaction for ML/AI training
      _logInteraction(amount, expectedReturn);

      _amountController.clear();
      _expectedReturnController.clear();
      setState(() {});
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

  Future<void> _generateRecommendations(double amount, double expectedReturn) async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    List<String> recommendations = [];
    List<String> warnings = [];
    List<String> insights = [];

    // Calculate total investments
    double totalInvestments = (appState.investments.isNotEmpty ? appState.investments.map((i) => i.amount).reduce((a, b) => a + b) : 0.0) + amount;
    
    // Calculate total goals
    double totalGoalAmount = appState.goals.isNotEmpty ? appState.goals.map((g) => g.targetAmount - g.currentAmount).reduce((a, b) => a + b) : 0.0;
    
    // Calculate total EMI commitments
    double totalEMI = appState.loans.isNotEmpty ? appState.loans.map((l) => l.emiAmount).reduce((a, b) => a + b) : 0.0;

    // Investment amount analysis
    if (appState.taxProfile != null) {
      double monthlyIncome = appState.taxProfile!.income / 12;
      double investmentToIncomeRatio = (amount / monthlyIncome) * 100;
      
      if (investmentToIncomeRatio > 50) {
        warnings.add('⚠️ Investment amount (${investmentToIncomeRatio.toStringAsFixed(1)}% of monthly income) is quite high');
      } else if (investmentToIncomeRatio > 30) {
        recommendations.add('✅ Investment amount is reasonable (${investmentToIncomeRatio.toStringAsFixed(1)}% of monthly income)');
      } else {
        recommendations.add('✅ Investment amount is conservative and safe');
      }
    }

    // Portfolio diversification analysis
    if (appState.investments.isNotEmpty) {
      var typeCounts = <String, int>{};
      for (var inv in appState.investments) {
        typeCounts[inv.type] = (typeCounts[inv.type] ?? 0) + 1;
      }
      typeCounts[_investmentType] = (typeCounts[_investmentType] ?? 0) + 1;
      
      if (typeCounts.length < 3) {
        recommendations.add('💡 Consider diversifying across more investment types for better risk management');
      } else {
        recommendations.add('✅ Good portfolio diversification across ${typeCounts.length} investment types');
      }
    }

    // Risk-return analysis
    if (appState.investments.isNotEmpty) {
      double avgReturn = appState.investments.map((i) => i.expectedReturn).reduce((a, b) => a + b) / appState.investments.length;
      
      if (expectedReturn > avgReturn + 5) {
        warnings.add('⚠️ Expected return (${expectedReturn.toStringAsFixed(1)}%) is significantly higher than your portfolio average (${avgReturn.toStringAsFixed(1)}%)');
      } else if (expectedReturn < avgReturn - 3) {
        insights.add('💡 This investment has lower returns than your portfolio average - consider if it aligns with your goals');
      }
    }

    // Goal alignment analysis
    if (appState.goals.isNotEmpty) {
      double totalRequiredForGoals = totalGoalAmount;
      double totalAvailableForInvestment = totalInvestments;
      
      if (totalAvailableForInvestment > totalRequiredForGoals * 0.8) {
        recommendations.add('✅ Your investments are well-aligned with your financial goals');
      } else {
        insights.add('💡 Consider increasing investment amount to better meet your financial goals');
      }
    }

    // EMI vs Investment comparison
    if (totalEMI > 0) {
      double emiToInvestmentRatio = (totalEMI / totalInvestments) * 100;
      if (emiToInvestmentRatio > 100) {
        warnings.add('⚠️ Your EMI commitments exceed your total investments - consider reducing debt first');
      } else if (emiToInvestmentRatio > 50) {
        insights.add('💡 High EMI commitments may limit your investment capacity');
      }
    }

    // Risk profile consistency
    if (appState.investments.isNotEmpty) {
      var riskProfiles = appState.investments.map((i) => i.riskProfile).toList();
      riskProfiles.add(_riskProfile);
      
      if (riskProfiles.where((r) => r == 'High').length > riskProfiles.length * 0.5) {
        warnings.add('⚠️ Your portfolio has a high concentration of high-risk investments');
      }
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
        'totalInvestments': totalInvestments,
        'totalGoals': totalGoalAmount,
        'totalEMI': totalEMI,
      };
    });
  }

  void _logInteraction(double amount, double expectedReturn) {
    final appState = Provider.of<AppState>(context, listen: false);
    final financialSnapshot = appState.getUserFinancialSnapshot();
    
    // Create interaction log for ML/AI training
    final interactionLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'tool': 'investment_calculator',
      'action': 'add_investment',
      'input': {
        'amount': amount,
        'expectedReturn': expectedReturn,
        'investmentType': _investmentType,
        'riskProfile': _riskProfile,
      },
      'output': {
        'totalInvestments': (appState.investments.isNotEmpty ? appState.investments.map((i) => i.amount).reduce((a, b) => a + b) : 0.0) + amount,
        'portfolioDiversification': appState.investments.map((i) => i.type).toSet().length + 1,
      },
      'userFinancialSnapshot': financialSnapshot,
      'recommendations': _recommendations,
    };

    // In a real app, you would send this to your ML/AI backend
    print('ML/AI Training Data: ${jsonEncode(interactionLog)}');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _expectedReturnController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final investments = appState.investments;
    
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: 'Investment Calculator',
      ),
      endDrawer: const FinwiseDrawer(),
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
                  DropdownButtonFormField<String>(
                    value: _investmentType,
                    items: [
                      'SIP',
                      'FD',
                      'Stocks',
                      'Mutual Fund',
                    ].map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _investmentType = val);
                    },
                    decoration: const InputDecoration(labelText: 'Investment Type'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _expectedReturnController,
                    decoration: const InputDecoration(
                      labelText: 'Expected Return (%)',
                      suffixText: '%',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expected return';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _riskProfile,
                    items: [
                      'Low',
                      'Moderate',
                      'High',
                    ].map((risk) => DropdownMenuItem(
                          value: risk,
                          child: Text(risk),
                        )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _riskProfile = val);
                    },
                    decoration: const InputDecoration(labelText: 'Risk Profile'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _addInvestment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: const Size(double.infinity, 50),
      ),
                    child: const Text(
                      'Add Investment & Get Analysis',
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
            Text('Your Investments:', style: Theme.of(context).textTheme.titleMedium),
            ...investments.map((inv) => ListTile(
                  title: Text(inv.type),
                  subtitle: Text('Return: ${inv.expectedReturn}% | Risk: ${inv.riskProfile}'),
                  trailing: Text('₹${inv.amount.toStringAsFixed(0)}'),
                )),
          ],
        ),
      ),
    );
  }
} 