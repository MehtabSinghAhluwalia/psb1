class FinancialGoal {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String category;
  final String icon;

  FinancialGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.category,
    required this.icon,
  });

  double get progress => currentAmount / targetAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'category': category,
      'icon': icon,
    };
  }

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'],
      targetDate: DateTime.parse(json['targetDate']),
      category: json['category'],
      icon: json['icon'],
    );
  }
} 