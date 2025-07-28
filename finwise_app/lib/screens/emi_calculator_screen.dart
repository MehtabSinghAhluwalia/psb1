import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/app_state.dart';
import 'dart:convert';
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:finwise_app/providers/language_provider.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';
import 'package:http/http.dart' as http;

class EMICalculatorScreen extends StatefulWidget {
  const EMICalculatorScreen({super.key});

  @override
  State<EMICalculatorScreen> createState() => _EMICalculatorScreenState();
}

class _EMICalculatorScreenState extends State<EMICalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _interestController = TextEditingController();
  final _tenureController = TextEditingController();
  String _selectedTenureType = 'Years';
  String _loanType = 'Personal Loan';
  Map<String, dynamic>? _calculationResult;
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
    
    // Pre-fill with existing loan data if available
    if (appState.loans.isNotEmpty) {
      final lastLoan = appState.loans.last;
      _principalController.text = lastLoan.principal.toString();
      _interestController.text = lastLoan.interestRate.toString();
      _tenureController.text = (lastLoan.tenureMonths / 12).toString();
      _selectedTenureType = 'Years';
      _loanType = lastLoan.type;
    }
  }

  void _calculateEMI() {
    if (_formKey.currentState!.validate()) {
      final principal = double.parse(_principalController.text);
      final interestRate = double.parse(_interestController.text);
      final tenure = int.parse(_tenureController.text);
      final tenureMonths = _selectedTenureType == 'Years' ? tenure * 12 : tenure;
      final monthlyInterest = interestRate / 12 / 100;
      final emi = (principal * monthlyInterest *
              (pow(1 + monthlyInterest, tenureMonths))) /
          (pow(1 + monthlyInterest, tenureMonths) - 1);
      final totalPayment = emi * tenureMonths;
      final totalInterest = totalPayment - principal;

      setState(() {
        _calculationResult = {
          'monthlyEMI': emi,
          'totalInterest': totalInterest,
          'totalPayment': totalPayment,
        };
      });

      // Generate recommendations and analysis using AppState data
      _generateRecommendations(principal, emi, tenureMonths);

      // Add loan to AppState
      Provider.of<AppState>(context, listen: false).addLoan(
        Loan(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: _loanType,
          principal: principal,
          interestRate: interestRate,
          tenureMonths: tenureMonths,
          emiAmount: emi,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: tenureMonths * 30)),
        ),
      );

      // Log interaction for ML/AI training
      _logInteraction(principal, emi, tenureMonths);
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

  Future<void> _generateRecommendations(double principal, double emi, int tenureMonths) async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Calculate total monthly commitments
    double totalMonthlyCommitments = 0;
    for (var loan in appState.loans) {
      totalMonthlyCommitments += loan.emiAmount;
    }
    totalMonthlyCommitments += emi; // Include new loan

    // Calculate total goal requirements
    double totalGoalAmount = 0;
    for (var goal in appState.goals) {
      totalGoalAmount += goal.targetAmount - goal.currentAmount;
    }

    // Calculate total investments
    double totalInvestments = 0;
    for (var investment in appState.investments) {
      totalInvestments += investment.amount;
    }

    // Generate recommendations
    List<String> recommendations = [];
    List<String> warnings = [];

    // EMI affordability check (assuming 40% of income rule)
    if (appState.taxProfile != null) {
      double monthlyIncome = appState.taxProfile!.income / 12;
      double emiToIncomeRatio = (totalMonthlyCommitments / monthlyIncome) * 100;
      
      if (emiToIncomeRatio > 40) {
        warnings.add('⚠️ Your EMI commitments (${emiToIncomeRatio.toStringAsFixed(1)}% of income) exceed the recommended 40% limit');
      } else {
        recommendations.add('✅ EMI commitments are within safe limits (${emiToIncomeRatio.toStringAsFixed(1)}% of income)');
      }
    }

    // Goal impact analysis
    if (appState.goals.isNotEmpty) {
      double monthlyGoalSavings = totalGoalAmount / 12; // Simplified calculation
      if (emi > monthlyGoalSavings * 0.5) {
        warnings.add('⚠️ This EMI may significantly impact your goal savings');
      } else {
        recommendations.add('✅ EMI amount is manageable with your current goals');
      }
    }

    // Investment comparison
    if (appState.investments.isNotEmpty) {
      double avgInvestmentReturn = appState.investments
          .map((i) => i.expectedReturn)
          .reduce((a, b) => a + b) / appState.investments.length;
      
      double currentInterestRate = double.parse(_interestController.text);
      if (currentInterestRate > avgInvestmentReturn) {
        recommendations.add('💡 Consider using investments to reduce loan amount (investment return: ${avgInvestmentReturn.toStringAsFixed(1)}% vs loan rate: ${currentInterestRate.toStringAsFixed(1)}%)');
      }
    }

    // Tenure optimization
    if (tenureMonths > 60) { // 5 years
      recommendations.add('💡 Longer tenure reduces monthly burden but increases total interest');
    }

    // Multilingual translation logic
    final lang = Provider.of<LanguageProvider>(context, listen: false).locale.languageCode;
    if (lang != 'en') {
      recommendations = await Future.wait(recommendations.map((r) async => await _translateText(r, lang)));
      warnings = await Future.wait(warnings.map((w) async => await _translateText(w, lang)));
    }
    setState(() {
      _recommendations = {
        'recommendations': recommendations,
        'warnings': warnings,
        'totalMonthlyCommitments': totalMonthlyCommitments,
        'totalGoalAmount': totalGoalAmount,
        'totalInvestments': totalInvestments,
      };
    });
  }

  void _logInteraction(double principal, double emi, int tenureMonths) {
    final appState = Provider.of<AppState>(context, listen: false);
    final financialSnapshot = appState.getUserFinancialSnapshot();
    
    // Create interaction log for ML/AI training
    final interactionLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'tool': 'emi_calculator',
      'action': 'calculate_emi',
      'input': {
        'principal': principal,
        'interestRate': double.parse(_interestController.text),
        'tenureMonths': tenureMonths,
        'loanType': _loanType,
      },
      'output': {
        'monthlyEMI': emi,
        'totalInterest': _calculationResult!['totalInterest'],
        'totalPayment': _calculationResult!['totalPayment'],
      },
      'userFinancialSnapshot': financialSnapshot,
      'recommendations': _recommendations,
    };

    // In a real app, you would send this to your ML/AI backend
    print('ML/AI Training Data: ${jsonEncode(interactionLog)}');
    }

  @override
  void dispose() {
    _principalController.dispose();
    _interestController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final loans = appState.loans;
    
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: 'EMI Calculator',
      ),
      endDrawer: const FinwiseDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Financial Summary Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Financial Overview',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Active Loans: ${loans.length}'),
                      Text('Total Goals: ${appState.goals.length}'),
                      Text('Total Investments: ${appState.investments.length}'),
                      if (appState.taxProfile != null)
                        Text('Monthly Income: ${_currencyFormat.format(appState.taxProfile!.income / 12)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _loanType,
                items: [
                  'Personal Loan',
                  'Home Loan',
                  'Car Loan',
                  'Education Loan',
                ].map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _loanType = val);
                },
                decoration: const InputDecoration(labelText: 'Loan Type'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _principalController,
                        decoration: const InputDecoration(
                          labelText: 'Loan Amount',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter loan amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _interestController,
                        decoration: const InputDecoration(
                          labelText: 'Interest Rate (%)',
                          suffixText: '%',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter interest rate';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tenureController,
                              decoration: const InputDecoration(
                                labelText: 'Loan Tenure',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter tenure';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _selectedTenureType,
                            items: ['Years', 'Months'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedTenureType = newValue;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _calculateEMI,
                        style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                  'Calculate EMI & Get Recommendations',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              
              // Results Section
              if (_calculationResult != null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMI Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildResultRow(
                          'Monthly EMI',
                          _currencyFormat.format(_calculationResult!['monthlyEMI']),
                        ),
                        const Divider(),
                        _buildResultRow(
                          'Total Interest',
                          _currencyFormat.format(_calculationResult!['totalInterest']),
                        ),
                        const Divider(),
                        _buildResultRow(
                          'Total Payment',
                          _currencyFormat.format(_calculationResult!['totalPayment']),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Recommendations Section
              if (_recommendations != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Recommendations & Analysis',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_recommendations!['recommendations'].isNotEmpty) ...[
                          Text(
                            'Recommendations:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...(_recommendations!['recommendations'] as List<String>)
                              .map((rec) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text('• $rec'),
                                  ))
                              .toList(),
                          const SizedBox(height: 16),
                        ],
                        if (_recommendations!['warnings'].isNotEmpty) ...[
                          Text(
                            '⚠️ Warnings:',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                          const SizedBox(height: 8),
                          ...(_recommendations!['warnings'] as List<String>)
                              .map((warning) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text('• $warning', style: const TextStyle(color: Colors.orange)),
                                  ))
                              .toList(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              Text('Your Loans:', style: Theme.of(context).textTheme.titleMedium),
              ...loans.map((loan) => ListTile(
                    title: Text(loan.type),
                    subtitle: Text('EMI: ₹${loan.emiAmount.toStringAsFixed(2)}'),
                    trailing: Text('₹${loan.principal.toStringAsFixed(0)}'),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
} 