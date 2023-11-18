// Bazowa klasa dla obiektów finansowych
class FinancialItem {
  final String userId;
  final String name;
  final DateTime date;
  final double amount;
  final String currency;

  FinancialItem({
    required this.userId,
    required this.name,
    required this.date,
    required this.amount,
    required this.currency,
  });
}