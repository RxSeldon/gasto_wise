import 'package:flutter/material.dart';

abstract class AppConstants {
  static const String appName = 'GastoWise';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Smart Expense and Budget Tracker';

  static const List<String> categories = [
    'Food',
    'Transportation',
    'Shopping',
    'Bills',
    'School',
    'Entertainment',
    'Others',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Bills': Icons.receipt_long,
    'School': Icons.school,
    'Entertainment': Icons.movie,
    'Others': Icons.category,
  };

  static const double defaultBudget = 0.0;
  static const int minPasswordLength = 6;
}
