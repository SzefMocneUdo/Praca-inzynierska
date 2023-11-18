// Klasa dla przychodów dziedzicząca po FinancialItem
import 'package:cloud_firestore/cloud_firestore.dart';

import 'FinancialItem.dart';

class Income extends FinancialItem {
  Income({
    required String userId,
    required String name,
    required DateTime date,
    required double amount,
    required String currency,
    String type = "Income"
  }) : super(
    userId: userId,
    name: name,
    date: date,
    amount: amount,
    currency: currency,
  );

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      amount: map['amount'] != null ? map['amount'].toDouble() : 0.0,
      currency: map['currency'] ?? '',
    );
  }
}