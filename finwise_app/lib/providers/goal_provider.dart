import 'package:flutter/foundation.dart';
import '../models/financial_goal.dart';
import '../services/goal_service.dart';

class GoalProvider with ChangeNotifier {
  final GoalService _goalService = GoalService();
  List<FinancialGoal> _goals = [];
  bool _isLoading = false;

  List<FinancialGoal> get goals => _goals;
  bool get isLoading => _isLoading;

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = await _goalService.getGoals();
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(FinancialGoal goal) async {
    try {
      await _goalService.addGoal(goal);
      _goals.add(goal);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding goal: $e');
    }
  }

  Future<void> updateGoal(FinancialGoal goal) async {
    try {
      await _goalService.updateGoal(goal);
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating goal: $e');
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _goalService.deleteGoal(id);
      _goals.removeWhere((goal) => goal.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
    }
  }
} 