import 'package:flutter/foundation.dart';

class GoalsProvider extends ChangeNotifier {
  final List<FinancialGoal> _goals = [];
  double _totalSavings = 0.0;

  List<FinancialGoal> get goals => _goals;
  double get totalSavings => _totalSavings;

  void addGoal(FinancialGoal goal) {
    _goals.add(goal);
    _updateTotalSavings();
    notifyListeners();
  }

  void removeGoal(int index) {
    if (index >= 0 && index < _goals.length) {
      _goals.removeAt(index);
      _updateTotalSavings();
      notifyListeners();
    }
  }

  void updateGoal(int index, FinancialGoal updatedGoal) {
    if (index >= 0 && index < _goals.length) {
      _goals[index] = updatedGoal;
      _updateTotalSavings();
      notifyListeners();
    }
  }

  void _updateTotalSavings() {
    _totalSavings = _goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  }
}

class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  double currentAmount;
  final DateTime targetDate;
  final String category;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.category,
  });

  double get progress => (currentAmount / targetAmount) * 100;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
} 