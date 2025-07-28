import 'dart:math';
import '../models/calculator_result.dart';

class CalculatorService {
  static Map<String, dynamic> calculateEMI({
    required double principal,
    required double interestRate,
    required int tenure,
    required String tenureType,
  }) {
    // Convert annual interest rate to monthly
    double monthlyRate = interestRate / 12 / 100;
    
    // Convert tenure to months if in years
    int tenureInMonths = tenureType == 'Years' ? tenure * 12 : tenure;
    
    // Calculate EMI using the formula: EMI = P * r * (1 + r)^n / ((1 + r)^n - 1)
    double emi = principal * monthlyRate * 
        pow(1 + monthlyRate, tenureInMonths) / 
        (pow(1 + monthlyRate, tenureInMonths) - 1);
    
    // Calculate total payment and interest
    double totalPayment = emi * tenureInMonths;
    double totalInterest = totalPayment - principal;
    
    return {
      'monthlyEMI': emi,
      'totalPayment': totalPayment,
      'totalInterest': totalInterest,
    };
  }

  double calculateInvestment({
    required double principal,
    required double annualInterestRate,
    required int years,
    required bool isCompound,
  }) {
    if (isCompound) {
      return principal * pow(1 + annualInterestRate / 100, years);
    } else {
      return principal * (1 + (annualInterestRate / 100) * years);
    }
  }

  double calculateTax({
    required double annualIncome,
    required double deductions,
  }) {
    final taxableIncome = annualIncome - deductions;
    double tax = 0;

    if (taxableIncome <= 250000) {
      tax = 0;
    } else if (taxableIncome <= 500000) {
      tax = (taxableIncome - 250000) * 0.05;
    } else if (taxableIncome <= 1000000) {
      tax = 12500 + (taxableIncome - 500000) * 0.2;
    } else {
      tax = 112500 + (taxableIncome - 1000000) * 0.3;
    }

    return tax;
  }

  double calculateRetirement({
    required double currentAge,
    required double retirementAge,
    required double monthlyExpenses,
    required double inflationRate,
    required double expectedReturn,
  }) {
    final yearsToRetirement = retirementAge - currentAge;
    final monthlyExpensesAtRetirement = monthlyExpenses *
        pow(1 + inflationRate / 100, yearsToRetirement);
    final annualExpensesAtRetirement = monthlyExpensesAtRetirement * 12;
    final corpusNeeded = annualExpensesAtRetirement /
        (expectedReturn / 100) *
        (1 - pow(1 + expectedReturn / 100, -30));

    return corpusNeeded;
  }
} 