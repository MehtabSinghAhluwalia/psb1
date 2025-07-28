import 'package:flutter/material.dart';
import 'dart:convert';

class Goal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String category;
  final int priority;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.category,
    required this.priority,
  });
}

class Loan {
  final String id;
  final String type;
  final double principal;
  final double interestRate;
  final int tenureMonths;
  final double emiAmount;
  final DateTime startDate;
  final DateTime endDate;

  Loan({
    required this.id,
    required this.type,
    required this.principal,
    required this.interestRate,
    required this.tenureMonths,
    required this.emiAmount,
    required this.startDate,
    required this.endDate,
  });
}

class Investment {
  final String id;
  final String type;
  final double amount;
  final double expectedReturn;
  final String riskProfile;
  final DateTime startDate;
  final DateTime endDate;

  Investment({
    required this.id,
    required this.type,
    required this.amount,
    required this.expectedReturn,
    required this.riskProfile,
    required this.startDate,
    required this.endDate,
  });
}

class TaxProfile {
  final double income;
  final double deductions;
  final String regime;
  final String slab;
  final double lastYearTax;

  TaxProfile({
    required this.income,
    required this.deductions,
    required this.regime,
    required this.slab,
    required this.lastYearTax,
  });
}

class RetirementPlan {
  final int currentAge;
  final int retirementAge;
  final double currentSavings;
  final double expectedExpenses;
  final double inflationRate;

  RetirementPlan({
    required this.currentAge,
    required this.retirementAge,
    required this.currentSavings,
    required this.expectedExpenses,
    required this.inflationRate,
  });
}

class AppState extends ChangeNotifier {
  List<Goal> goals = [];
  List<Loan> loans = [];
  List<Investment> investments = [];
  TaxProfile? taxProfile;
  RetirementPlan? retirementPlan;

  // Add methods to update each section and call notifyListeners()
  void addGoal(Goal goal) {
    goals.add(goal);
    notifyListeners();
  }

  void addLoan(Loan loan) {
    loans.add(loan);
    notifyListeners();
  }

  void addInvestment(Investment investment) {
    investments.add(investment);
    notifyListeners();
  }

  void setTaxProfile(TaxProfile profile) {
    taxProfile = profile;
    notifyListeners();
  }

  void setRetirementPlan(RetirementPlan plan) {
    retirementPlan = plan;
    notifyListeners();
  }
}

extension AppStateML on AppState {
  Map<String, dynamic> getUserFinancialSnapshot() {
    return {
      'goals': goals.map((g) => {
        'title': g.title,
        'targetAmount': g.targetAmount,
        'currentAmount': g.currentAmount,
        'targetDate': g.targetDate.toIso8601String(),
        'category': g.category,
        'priority': g.priority,
      }).toList(),
      'loans': loans.map((l) => {
        'type': l.type,
        'principal': l.principal,
        'interestRate': l.interestRate,
        'tenureMonths': l.tenureMonths,
        'emiAmount': l.emiAmount,
      }).toList(),
      'investments': investments.map((i) => {
        'type': i.type,
        'amount': i.amount,
        'expectedReturn': i.expectedReturn,
        'riskProfile': i.riskProfile,
      }).toList(),
      'taxProfile': taxProfile != null ? {
        'income': taxProfile!.income,
        'deductions': taxProfile!.deductions,
        'regime': taxProfile!.regime,
        'slab': taxProfile!.slab,
        'lastYearTax': taxProfile!.lastYearTax,
      } : null,
      'retirementPlan': retirementPlan != null ? {
        'currentAge': retirementPlan!.currentAge,
        'retirementAge': retirementPlan!.retirementAge,
        'currentSavings': retirementPlan!.currentSavings,
        'expectedExpenses': retirementPlan!.expectedExpenses,
        'inflationRate': retirementPlan!.inflationRate,
      } : null,
    };
  }

  String exportUserDataAsJson() {
    final snapshot = getUserFinancialSnapshot();
    return jsonEncode(snapshot);
  }
} 