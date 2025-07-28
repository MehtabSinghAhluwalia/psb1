import 'package:flutter/material.dart';
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'package:finwise_app/l10n/app_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// Removed dart:html import for mobile compatibility

class BudgetCalculatorScreen extends StatefulWidget {
  const BudgetCalculatorScreen({super.key});

  @override
  State<BudgetCalculatorScreen> createState() => _BudgetCalculatorScreenState();
}

class _BudgetCalculatorScreenState extends State<BudgetCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyIncomeController = TextEditingController();
  final _monthlyExpensesController = TextEditingController();
  
  String _selectedSavingsGoal = 'Emergency Fund';
  String _selectedTimeFrame = '6 months';
  bool _isLoading = false;
  Map<String, dynamic>? _recommendations;

  final List<String> _savingsGoals = [
    'Emergency Fund',
    'Vacation',
    'House',
    'Education',
    'Retirement',
    'General Savings'
  ];

  final List<String> _timeFrames = [
    '3 months',
    '6 months',
    '1 year',
    '2 years',
    '5 years'
  ];

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
    _monthlyExpensesController.dispose();
    super.dispose();
  }

  Future<void> _getBudgetRecommendations() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current language code
      String currentLang = Localizations.localeOf(context).languageCode;
      
      final response = await http.post(
        Uri.parse('http://192.168.1.2:5001/recommend_budget'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'monthlyIncome': double.parse(_monthlyIncomeController.text),
          'monthlyExpenses': double.parse(_monthlyExpensesController.text),
          'savingsGoal': _selectedSavingsGoal,
          'timeFrame': _selectedTimeFrame,
          'target_lang': currentLang,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recommendations = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get recommendations')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildRecommendationsCard() {
    if (_recommendations == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Budget Recommendations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Recommended Savings
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Monthly Savings:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${_recommendations!['recommended_savings'].toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Budget Breakdown
            Text(
              'Budget Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBudgetItem('Essentials', _recommendations!['budget_breakdown']['essentials'], Colors.red.shade100),
            _buildBudgetItem('Wants', _recommendations!['budget_breakdown']['wants'], Colors.orange.shade100),
            _buildBudgetItem('Savings', _recommendations!['budget_breakdown']['savings'], Colors.green.shade100),
            
            const SizedBox(height: 16),

            // Investment Recommendation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Investment Recommendation:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recommendations!['investment_recommendation']['type'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _recommendations!['investment_recommendation']['reason'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // Tips and Warnings
            if (_recommendations!['tips'].isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tips:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...(_recommendations!['tips'] as List<dynamic>).map((tip) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tip.toString())),
                    ],
                  ),
                ),
              ).toList(),
            ],

            if (_recommendations!['warnings'].isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Warnings:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...(_recommendations!['warnings'] as List<dynamic>).map((warning) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(warning.toString())),
                    ],
                  ),
                ),
              ).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetItem(String title, Map<String, dynamic> data, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${data['percentage'].toStringAsFixed(0)}%'),
            ],
          ),
          Text(
            '₹${data['amount'].toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinwiseAppBar(
        context: context,
        subtitle: AppLocalizations.of(context)!.budgetCalculator,
      ),
      endDrawer: const FinwiseDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Budget Calculator',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get personalized budget recommendations based on your income and goals',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Monthly Income
              TextFormField(
                controller: _monthlyIncomeController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Income (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your monthly income';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Monthly Expenses
              TextFormField(
                controller: _monthlyExpensesController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Expenses (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_cart),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your monthly expenses';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Savings Goal
              DropdownButtonFormField<String>(
                value: _selectedSavingsGoal,
                decoration: const InputDecoration(
                  labelText: 'Savings Goal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: _savingsGoals.map((goal) => DropdownMenuItem(
                  value: goal,
                  child: Text(goal),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSavingsGoal = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Time Frame
              DropdownButtonFormField<String>(
                value: _selectedTimeFrame,
                decoration: const InputDecoration(
                  labelText: 'Time Frame',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
                items: _timeFrames.map((time) => DropdownMenuItem(
                  value: time,
                  child: Text(time),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTimeFrame = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Get Recommendations Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _getBudgetRecommendations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Get Budget Recommendations',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              // Recommendations
              if (_recommendations != null) _buildRecommendationsCard(),
            ],
          ),
        ),
      ),
    );
  }
} 