class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String description;

  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  Expense copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}

class BudgetInfo {
  final double totalBudget;
  final double totalExpenses;
  final DateTime month;

  const BudgetInfo({
    required this.totalBudget,
    required this.totalExpenses,
    required this.month,
  });

  double get remainingBudget => totalBudget - totalExpenses;

  double get usagePercentage {
    if (totalBudget <= 0) return 0;
    return (totalExpenses / totalBudget * 100).clamp(0, 100).toDouble();
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });
}
