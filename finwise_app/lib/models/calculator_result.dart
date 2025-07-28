class CalculatorResult {
  final double monthlyPayment;
  final double totalPayment;
  final double totalInterest;
  final List<MonthlyBreakdown> monthlyBreakdown;

  CalculatorResult({
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
    required this.monthlyBreakdown,
  });
}

class MonthlyBreakdown {
  final int month;
  final double principal;
  final double interest;
  final double remainingBalance;

  MonthlyBreakdown({
    required this.month,
    required this.principal,
    required this.interest,
    required this.remainingBalance,
  });
} 