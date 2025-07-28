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

class TaxCalculatorScreen extends StatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  State<TaxCalculatorScreen> createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends State<TaxCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _deductionsController = TextEditingController();
  String _regime = 'Old';
  String _slab = '5%';
  final _lastYearTaxController = TextEditingController();
  Map<String, dynamic>? _recommendations;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

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
    
    // Pre-fill with existing tax profile data if available
    if (appState.taxProfile != null) {
      _incomeController.text = appState.taxProfile!.income.toString();
      _deductionsController.text = appState.taxProfile!.deductions.toString();
      _regime = appState.taxProfile!.regime;
      _slab = appState.taxProfile!.slab;
      _lastYearTaxController.text = appState.taxProfile!.lastYearTax.toString();
    }
  }

  void _saveTaxProfile() {
    print('DEBUG: Save Tax Profile button pressed');
    if (_formKey.currentState!.validate()) {
      print('DEBUG: Form validation passed');
      final income = double.parse(_incomeController.text);
      final deductions = double.parse(_deductionsController.text);
      final lastYearTax = double.parse(_lastYearTaxController.text);

      // Generate recommendations and analysis using AppState data
      print('DEBUG: Generating recommendations');
      _generateRecommendations(income, deductions, lastYearTax);

      print('DEBUG: Setting tax profile in AppState');
      Provider.of<AppState>(context, listen: false).setTaxProfile(
        TaxProfile(
          income: income,
          deductions: deductions,
          regime: _regime,
          slab: _slab,
          lastYearTax: lastYearTax,
        ),
      );

      // Log interaction for ML/AI training
      print('DEBUG: Logging interaction');
      _logInteraction(income, deductions, lastYearTax);

      setState(() {
        print('DEBUG: setState called after saving tax profile');
      });
    } else {
      print('DEBUG: Form validation failed');
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

  Future<void> _generateRecommendations(double income, double deductions, double lastYearTax) async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    List<String> recommendations = [];
    List<String> warnings = [];
    List<String> insights = [];

    // Calculate tax liability
    double taxableIncome = income - deductions;
    double estimatedTax = _calculateTax(taxableIncome, _regime, _slab);
    double taxSavings = lastYearTax - estimatedTax;

    // Tax optimization analysis
    double deductionRatio = (deductions / income) * 100;
    if (deductionRatio < 10) {
      warnings.add('⚠️ Your deductions (${deductionRatio.toStringAsFixed(1)}% of income) are low - consider tax-saving investments');
    } else if (deductionRatio > 30) {
      warnings.add('⚠️ Very high deductions (${deductionRatio.toStringAsFixed(1)}% of income) - verify all deductions are legitimate');
    } else {
      recommendations.add('✅ Good deduction ratio (${deductionRatio.toStringAsFixed(1)}% of income)');
    }

    // Tax regime comparison
    if (_regime == 'Old') {
      double newRegimeTax = _calculateTax(income, 'New', _slab);
      if (newRegimeTax < estimatedTax) {
        insights.add('💡 New tax regime could save you ₹${_currencyFormat.format(estimatedTax - newRegimeTax)}');
      } else {
        insights.add('💡 Old regime is beneficial for your income level');
      }
    }

    // Tax-saving investment recommendations
    if (appState.investments.isNotEmpty) {
      double totalInvestments = appState.investments.map((i) => i.amount).reduce((a, b) => a + b);
      double taxSavingInvestments = appState.investments
          .where((i) => ['ELSS', 'PPF', 'NPS', 'Tax Saving FD'].contains(i.type))
          .map((i) => i.amount)
          .reduce((a, b) => a + b);
      
      if (taxSavingInvestments < deductions * 0.5) {
        recommendations.add('💡 Consider increasing tax-saving investments to maximize deductions');
      } else {
        recommendations.add('✅ Good allocation to tax-saving investments');
      }
    }

    // Income vs goals analysis
    if (appState.goals.isNotEmpty) {
      double totalGoalAmount = appState.goals.map((g) => g.targetAmount - g.currentAmount).reduce((a, b) => a + b);
      double monthlyIncome = income / 12;
      double monthlyGoalSavings = totalGoalAmount / 12;
      double afterTaxIncome = (income - estimatedTax) / 12;
      
      if (monthlyGoalSavings > afterTaxIncome * 0.4) {
        warnings.add('⚠️ Your goals require significant portion of after-tax income - consider tax optimization');
      } else {
        insights.add('💡 After-tax income is sufficient for your financial goals');
      }
    }

    // EMI affordability check
    if (appState.loans.isNotEmpty) {
      double totalEMI = appState.loans.map((l) => l.emiAmount).reduce((a, b) => a + b);
      double monthlyIncome = income / 12;
      double afterTaxMonthlyIncome = (income - estimatedTax) / 12;
      double emiToIncomeRatio = (totalEMI / afterTaxMonthlyIncome) * 100;
      
      if (emiToIncomeRatio > 50) {
        warnings.add('⚠️ EMI commitments (${emiToIncomeRatio.toStringAsFixed(1)}% of after-tax income) are high');
      } else {
        insights.add('💡 EMI commitments are manageable with your after-tax income');
      }
    }

    // Tax efficiency analysis
    double effectiveTaxRate = (estimatedTax / income) * 100;
    if (effectiveTaxRate > 20) {
      insights.add('💡 Your effective tax rate is ${effectiveTaxRate.toStringAsFixed(1)}% - consider tax planning strategies');
    } else {
      recommendations.add('✅ Good tax efficiency with ${effectiveTaxRate.toStringAsFixed(1)}% effective tax rate');
    }

    // Year-over-year comparison
    if (taxSavings > 0) {
      recommendations.add('🎉 Tax savings of ₹${_currencyFormat.format(taxSavings)} compared to last year!');
    } else if (taxSavings < 0) {
      warnings.add('⚠️ Tax liability increased by ₹${_currencyFormat.format(-taxSavings)} from last year');
    } else {
      insights.add('📊 Tax liability is similar to last year');
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
        'taxableIncome': taxableIncome,
        'estimatedTax': estimatedTax,
        'taxSavings': taxSavings,
        'effectiveTaxRate': effectiveTaxRate,
        'deductionRatio': deductionRatio,
      };
    });
  }

  double _calculateTax(double taxableIncome, String regime, String slab) {
    // Simplified tax calculation
    double taxRate = double.parse(slab.replaceAll('%', ''));
    return (taxableIncome * taxRate) / 100;
  }

  void _logInteraction(double income, double deductions, double lastYearTax) {
    final appState = Provider.of<AppState>(context, listen: false);
    final financialSnapshot = appState.getUserFinancialSnapshot();
    
    final interactionLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'tool': 'tax_calculator',
      'action': 'save_tax_profile',
      'input': {
        'income': income,
        'deductions': deductions,
        'regime': _regime,
        'slab': _slab,
        'lastYearTax': lastYearTax,
      },
      'output': {
        'taxableIncome': income - deductions,
        'estimatedTax': _calculateTax(income - deductions, _regime, _slab),
        'effectiveTaxRate': (_calculateTax(income - deductions, _regime, _slab) / income) * 100,
      },
      'userFinancialSnapshot': financialSnapshot,
      'recommendations': _recommendations,
    };

    print('ML/AI Training Data: ${jsonEncode(interactionLog)}');
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _deductionsController.dispose();
    _lastYearTaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final taxProfile = appState.taxProfile;
    
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: 'Tax Calculator',
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
                  TextFormField(
                    controller: _incomeController,
                    decoration: const InputDecoration(
                      labelText: 'Annual Income',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter income';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deductionsController,
                    decoration: const InputDecoration(
                      labelText: 'Deductions',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter deductions';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _regime,
                    items: ['Old', 'New'].map((regime) => DropdownMenuItem(
                          value: regime,
                          child: Text(regime),
                        )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _regime = val);
                    },
                    decoration: const InputDecoration(labelText: 'Tax Regime'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _slab,
                    items: ['5%', '10%', '15%', '20%', '30%']
                        .map((slab) => DropdownMenuItem(
                              value: slab,
                              child: Text(slab),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _slab = val);
                    },
                    decoration: const InputDecoration(labelText: 'Tax Slab'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastYearTaxController,
                    decoration: const InputDecoration(
                      labelText: 'Last Year Tax Paid',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
      ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last year tax';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveTaxProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Save Tax Profile & Get Analysis',
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
            if (taxProfile != null) ...[
              Text('Your Tax Profile:', style: Theme.of(context).textTheme.titleMedium),
              ListTile(
                title: Text('Income: ${_currencyFormat.format(taxProfile.income)}'),
                subtitle: Text('Deductions: ${_currencyFormat.format(taxProfile.deductions)}'),
                trailing: Text('Regime: ${taxProfile.regime}'),
              ),
              ListTile(
                title: Text('Tax Slab: ${taxProfile.slab}'),
                subtitle: Text('Last Year Tax: ${_currencyFormat.format(taxProfile.lastYearTax)}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 