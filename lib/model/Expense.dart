import 'package:cloud_firestore/cloud_firestore.dart';

import 'FinancialItem.dart';

class Expense extends FinancialItem {
  final String category;
  final String description;
  final String paymentMethod;

  Expense(
      {required String userId,
      required String name,
      required DateTime date,
      required double amount,
      required String currency,
      required this.category,
      required this.description,
      required this.paymentMethod,
      String type = "Expense"})
      : super(
          userId: userId,
          name: name,
          date: date,
          amount: amount,
          currency: currency,
        );

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      amount: map['amount'] != null ? map['amount'].toDouble() : 0.0,
      currency: map['currency'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
    );
  }
}
