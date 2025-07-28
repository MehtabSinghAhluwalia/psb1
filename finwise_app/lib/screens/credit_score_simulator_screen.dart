import 'package:flutter/material.dart';
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'package:finwise_app/l10n/app_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// Removed dart:html import for mobile compatibility

class CreditScoreSimulatorScreen extends StatefulWidget {
  const CreditScoreSimulatorScreen({super.key});

  @override
  State<CreditScoreSimulatorScreen> createState() => _CreditScoreSimulatorScreenState();
}

class _CreditScoreSimulatorScreenState extends State<CreditScoreSimulatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _creditUtilizationController = TextEditingController();
  final _creditAgeController = TextEditingController();
  final _newCreditController = TextEditingController();
  
  String _selectedPaymentHistory = 'Good';
  String _selectedCreditMix = 'Mixed';
  int _existingLoans = 0;
  int _existingCreditCards = 1;
  bool _isLoading = false;
  Map<String, dynamic>? _recommendations;

  final List<String> _paymentHistoryOptions = [
    'Excellent',
    'Good',
    'Fair',
    'Poor'
  ];

  final List<String> _creditMixOptions = [
    'Credit Cards',
    'Loans',
    'Mixed'
  ];

  @override
  void dispose() {
    _incomeController.dispose();
    _creditUtilizationController.dispose();
    _creditAgeController.dispose();
    _newCreditController.dispose();
    super.dispose();
  }

  Future<void> _getCreditScoreRecommendations() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current language code
      String currentLang = Localizations.localeOf(context).languageCode;
      
      final response = await http.post(
        Uri.parse('http://192.168.1.2:5001/recommend_credit_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'paymentHistory': _selectedPaymentHistory,
          'creditUtilization': double.parse(_creditUtilizationController.text),
          'creditAge': int.parse(_creditAgeController.text),
          'creditMix': _selectedCreditMix,
          'newCredit': int.parse(_newCreditController.text),
          'income': double.parse(_incomeController.text),
          'existingLoans': _existingLoans,
          'existingCreditCards': _existingCreditCards,
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
          const SnackBar(content: Text('Failed to get credit score analysis')),
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

  Widget _buildCreditScoreDisplay() {
    if (_recommendations == null) return const SizedBox.shrink();

    final score = _recommendations!['credit_score'];
    final range = _recommendations!['score_range'];
    final description = _recommendations!['score_description'];

    Color scoreColor;
    switch (range) {
      case 'Excellent':
        scoreColor = Colors.green;
        break;
      case 'Good':
        scoreColor = Colors.blue;
        break;
      case 'Fair':
        scoreColor = Colors.orange;
        break;
      case 'Poor':
      case 'Very Poor':
        scoreColor = Colors.red;
        break;
      default:
        scoreColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Credit Score Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Credit Score Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scoreColor),
              ),
              child: Column(
                children: [
                  Text(
                    score.toString(),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    range,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Credit Score Factors
            Text(
              'Credit Score Factors',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildFactorCard('Payment History', _recommendations!['factors']['payment_history']),
            _buildFactorCard('Credit Utilization', _recommendations!['factors']['credit_utilization']),
            _buildFactorCard('Credit Age', _recommendations!['factors']['credit_age']),
            _buildFactorCard('Credit Mix', _recommendations!['factors']['credit_mix']),
            _buildFactorCard('New Credit', _recommendations!['factors']['new_credit']),
            
            const SizedBox(height: 16),

            // Improvement Timeline
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
                    'Improvement Timeline:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recommendations!['improvement_timeline'],
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Tips and Warnings
            if (_recommendations!['tips'].isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Improvement Tips:',
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

            // Next Steps
            const SizedBox(height: 16),
            Text(
              'Next Steps:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...(_recommendations!['next_steps'] as List<dynamic>).map((step) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_forward, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(step.toString())),
                  ],
                ),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorCard(String title, Map<String, dynamic> factor) {
    Color impactColor;
    switch (factor['score_impact']) {
      case 'High':
      case 'Good':
        impactColor = Colors.green;
        break;
      case 'Fair':
        impactColor = Colors.orange;
        break;
      case 'Low':
      case 'Poor':
        impactColor = Colors.red;
        break;
      default:
        impactColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: impactColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: impactColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Impact: ${factor['impact']}'),
                Text('Status: ${factor['status']}'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: impactColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              factor['score_impact'],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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
        subtitle: 'Credit Score Simulator',
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
                'Credit Score Simulator',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Simulate your credit score and get personalized improvement recommendations',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Payment History
              DropdownButtonFormField<String>(
                value: _selectedPaymentHistory,
                decoration: const InputDecoration(
                  labelText: 'Payment History',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.history),
                ),
                items: _paymentHistoryOptions.map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentHistory = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select payment history' : null,
              ),
              const SizedBox(height: 16),

              // Credit Utilization
              TextFormField(
                controller: _creditUtilizationController,
                decoration: const InputDecoration(
                  labelText: 'Credit Utilization (%)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter credit utilization';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  final util = double.parse(value);
                  if (util < 0 || util > 100) {
                    return 'Please enter a percentage between 0-100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Credit Age
              TextFormField(
                controller: _creditAgeController,
                decoration: const InputDecoration(
                  labelText: 'Credit Age (Years)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter credit age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Credit Mix
              DropdownButtonFormField<String>(
                value: _selectedCreditMix,
                decoration: const InputDecoration(
                  labelText: 'Credit Mix',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                items: _creditMixOptions.map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCreditMix = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select credit mix' : null,
              ),
              const SizedBox(height: 16),

              // New Credit Applications
              TextFormField(
                controller: _newCreditController,
                decoration: const InputDecoration(
                  labelText: 'New Credit Applications (Last 12 months)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.add_circle),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of new applications';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Annual Income
              TextFormField(
                controller: _incomeController,
                decoration: const InputDecoration(
                  labelText: 'Annual Income (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your annual income';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Existing Loans
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _existingLoans.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Existing Loans',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _existingLoans = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _existingCreditCards.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Credit Cards',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _existingCreditCards = int.tryParse(value) ?? 1;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Get Recommendations Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _getCreditScoreRecommendations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simulate Credit Score',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              // Recommendations
              if (_recommendations != null) _buildCreditScoreDisplay(),
            ],
          ),
        ),
      ),
    );
  }
} 