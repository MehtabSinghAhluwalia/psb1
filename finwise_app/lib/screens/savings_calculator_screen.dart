import 'package:flutter/material.dart';
import '../services/savings_api_service.dart';

class SavingsCalculatorScreen extends StatefulWidget {
  @override
  _SavingsCalculatorScreenState createState() => _SavingsCalculatorScreenState();
}

class _SavingsCalculatorScreenState extends State<SavingsCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _expensesController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final TextEditingController _monthsToGoalController = TextEditingController();

  double? recommendedSaving;
  bool isLoading = false;
  String? errorMessage;

  Future<void> calculate() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await SavingsApiService.getRecommendedSaving(
        income: double.parse(_incomeController.text),
        expenses: double.parse(_expensesController.text),
        goalAmount: double.parse(_goalAmountController.text),
        monthsToGoal: double.parse(_monthsToGoalController.text),
      );
      setState(() {
        recommendedSaving = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to get recommendation.';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _expensesController.dispose();
    _goalAmountController.dispose();
    _monthsToGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Savings Recommendation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _incomeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Monthly Income'),
                validator: (value) => value == null || value.isEmpty ? 'Enter income' : null,
              ),
              TextFormField(
                controller: _expensesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Monthly Expenses'),
                validator: (value) => value == null || value.isEmpty ? 'Enter expenses' : null,
              ),
              TextFormField(
                controller: _goalAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Goal Amount'),
                validator: (value) => value == null || value.isEmpty ? 'Enter goal amount' : null,
              ),
              TextFormField(
                controller: _monthsToGoalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Months to Goal'),
                validator: (value) => value == null || value.isEmpty ? 'Enter months to goal' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : calculate,
                child: isLoading ? CircularProgressIndicator() : Text('Get Recommendation'),
              ),
              SizedBox(height: 24),
              if (recommendedSaving != null)
                Text('Recommended Saving: ₹${recommendedSaving!.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (errorMessage != null)
                Text(errorMessage!, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
} 