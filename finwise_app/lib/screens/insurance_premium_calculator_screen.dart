import 'package:flutter/material.dart';
import 'package:finwise_app/widgets/finwise_app_bar.dart';
import 'package:finwise_app/widgets/finwise_drawer.dart';
import 'package:finwise_app/theme/app_theme.dart';
import 'package:finwise_app/l10n/app_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// Removed dart:html import for mobile compatibility

class InsurancePremiumCalculatorScreen extends StatefulWidget {
  const InsurancePremiumCalculatorScreen({super.key});

  @override
  State<InsurancePremiumCalculatorScreen> createState() => _InsurancePremiumCalculatorScreenState();
}

class _InsurancePremiumCalculatorScreenState extends State<InsurancePremiumCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _incomeController = TextEditingController();
  final _familySizeController = TextEditingController();
  final _vehicleAgeController = TextEditingController();
  
  String _selectedHealthCondition = 'Good';
  String _selectedOccupation = 'Office';
  String _selectedExistingInsurance = 'None';
  String _selectedVehicleType = 'Car';
  String _selectedDrivingHistory = 'Good';
  bool _isLoading = false;
  Map<String, dynamic>? _recommendations;

  final List<String> _healthConditions = [
    'Excellent',
    'Good',
    'Fair',
    'Poor'
  ];

  final List<String> _occupations = [
    'Office',
    'Manual',
    'High Risk',
    'Professional'
  ];

  final List<String> _existingInsuranceOptions = [
    'None',
    'Basic',
    'Comprehensive'
  ];

  final List<String> _vehicleTypes = [
    'Car',
    'Bike',
    'Commercial'
  ];

  final List<String> _drivingHistoryOptions = [
    'Excellent',
    'Good',
    'Fair',
    'Poor'
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _incomeController.dispose();
    _familySizeController.dispose();
    _vehicleAgeController.dispose();
    super.dispose();
  }

  Future<void> _getInsuranceRecommendations() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current language code
      String currentLang = Localizations.localeOf(context).languageCode;
      
      final response = await http.post(
        Uri.parse('http://192.168.1.2:5001/recommend_insurance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'age': int.parse(_ageController.text),
          'income': double.parse(_incomeController.text),
          'healthCondition': _selectedHealthCondition,
          'occupation': _selectedOccupation,
          'familySize': int.parse(_familySizeController.text),
          'existingInsurance': _selectedExistingInsurance,
          'vehicleType': _selectedVehicleType,
          'vehicleAge': int.parse(_vehicleAgeController.text),
          'drivingHistory': _selectedDrivingHistory,
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
          const SnackBar(content: Text('Failed to get insurance recommendations')),
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

  Widget _buildInsuranceDisplay() {
    if (_recommendations == null) return const SizedBox.shrink();

    final premiums = _recommendations!['premiums'];
    final coverage = _recommendations!['coverage'];
    final adequacy = _recommendations!['coverage_adequacy'];

    Color adequacyColor;
    switch (adequacy) {
      case 'Excellent':
        adequacyColor = Colors.green;
        break;
      case 'Good':
        adequacyColor = Colors.blue;
        break;
      case 'Poor':
        adequacyColor = Colors.red;
        break;
      default:
        adequacyColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Insurance Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Premium Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: adequacyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: adequacyColor),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Annual Premium',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${premiums['total_annual'].toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: adequacyColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monthly: ₹${premiums['total_monthly'].toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: adequacyColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      adequacy,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Premium Breakdown
            Text(
              'Premium Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPremiumCard('Health Insurance', premiums['health_insurance'], Colors.green),
            _buildPremiumCard('Life Insurance', premiums['life_insurance'] * 12, Colors.blue),
            _buildPremiumCard('Vehicle Insurance', premiums['vehicle_insurance'], Colors.orange),
            
            const SizedBox(height: 16),

            // Coverage Summary
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
                    'Coverage Summary:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Life Coverage: ₹${coverage['life_coverage'].toStringAsFixed(0)}'),
                  Text('Health Coverage: ${coverage['health_coverage']}'),
                  Text('Vehicle Coverage: ${coverage['vehicle_coverage']}'),
                ],
              ),
            ),

            // Risk Assessment
            const SizedBox(height: 16),
            Text(
              'Risk Assessment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildRiskCard('Health Risk', _recommendations!['risk_assessment']['health_risk']),
            _buildRiskCard('Life Risk', _recommendations!['risk_assessment']['life_risk']),
            _buildRiskCard('Vehicle Risk', _recommendations!['risk_assessment']['vehicle_risk']),

            // Recommendations
            if (_recommendations!['recommendations'].isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recommendations:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...(_recommendations!['recommendations'] as List<dynamic>).map((rec) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.recommend, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(rec.toString())),
                    ],
                  ),
                ),
              ).toList(),
            ],

            // Tips
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

            // Warnings
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
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...(_recommendations!['next_steps'] as List<dynamic>).map((step) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_forward, color: Colors.purple, size: 16),
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

  Widget _buildPremiumCard(String title, double amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(String title, String risk) {
    Color riskColor;
    switch (risk) {
      case 'Low':
        riskColor = Colors.green;
        break;
      case 'Medium':
        riskColor = Colors.orange;
        break;
      case 'High':
        riskColor = Colors.red;
        break;
      default:
        riskColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: riskColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              risk,
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
        subtitle: 'Insurance Premium Calculator',
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
                'Insurance Premium Calculator',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get personalized insurance recommendations and premium estimates',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Age
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  final age = int.parse(value);
                  if (age < 18 || age > 100) {
                    return 'Please enter a valid age between 18-100';
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

              // Health Condition
              DropdownButtonFormField<String>(
                value: _selectedHealthCondition,
                decoration: const InputDecoration(
                  labelText: 'Health Condition',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.favorite),
                ),
                items: _healthConditions.map((condition) => DropdownMenuItem(
                  value: condition,
                  child: Text(condition),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHealthCondition = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select health condition' : null,
              ),
              const SizedBox(height: 16),

              // Occupation
              DropdownButtonFormField<String>(
                value: _selectedOccupation,
                decoration: const InputDecoration(
                  labelText: 'Occupation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                items: _occupations.map((occupation) => DropdownMenuItem(
                  value: occupation,
                  child: Text(occupation),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedOccupation = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select occupation' : null,
              ),
              const SizedBox(height: 16),

              // Family Size
              TextFormField(
                controller: _familySizeController,
                decoration: const InputDecoration(
                  labelText: 'Family Size',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter family size';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  final size = int.parse(value);
                  if (size < 1 || size > 10) {
                    return 'Please enter a valid family size between 1-10';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Existing Insurance
              DropdownButtonFormField<String>(
                value: _selectedExistingInsurance,
                decoration: const InputDecoration(
                  labelText: 'Existing Insurance',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                ),
                items: _existingInsuranceOptions.map((insurance) => DropdownMenuItem(
                  value: insurance,
                  child: Text(insurance),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedExistingInsurance = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select existing insurance' : null,
              ),
              const SizedBox(height: 16),

              // Vehicle Type
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                items: _vehicleTypes.map((vehicle) => DropdownMenuItem(
                  value: vehicle,
                  child: Text(vehicle),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVehicleType = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select vehicle type' : null,
              ),
              const SizedBox(height: 16),

              // Vehicle Age
              TextFormField(
                controller: _vehicleAgeController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Age (Years)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Driving History
              DropdownButtonFormField<String>(
                value: _selectedDrivingHistory,
                decoration: const InputDecoration(
                  labelText: 'Driving History',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.drive_eta),
                ),
                items: _drivingHistoryOptions.map((history) => DropdownMenuItem(
                  value: history,
                  child: Text(history),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDrivingHistory = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select driving history' : null,
              ),
              const SizedBox(height: 24),

              // Get Recommendations Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _getInsuranceRecommendations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Calculate Premiums',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              // Recommendations
              if (_recommendations != null) _buildInsuranceDisplay(),
            ],
          ),
        ),
      ),
    );
  }
} 