import 'dart:convert';
import 'dart:io';
import '../models/app_state.dart';

Future<void> exportGoalFeasibilityData(AppState appState, String filePath) async {
  final List<Map<String, dynamic>> data = [];

  for (final goal in appState.goals) {
    // Simulate outcome for now (1 if >95% complete, else 0)
    final achieved = (goal.currentAmount / goal.targetAmount) > 0.95 ? 1 : 0;

    data.add({
      'income': appState.taxProfile?.income ?? 0,
      'total_loans': appState.loans.fold(0.0, (sum, l) => sum + l.principal),
      'total_investments': appState.investments.fold(0.0, (sum, i) => sum + i.amount),
      'goal_amount': goal.targetAmount,
      'goal_priority': goal.priority,
      'goal_time_months': goal.targetDate.difference(DateTime.now()).inDays ~/ 30,
      'achieved': achieved,
    });
  }

  final file = File(filePath);
  await file.writeAsString(jsonEncode(data));
  print('Exported goal feasibility data to $filePath');
} 