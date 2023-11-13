
// Expense class
class Expense {
  final String userId;
  final String name;
  final DateTime date;
  final double amount;
  final String category;
  final String description;

  Expense({
    required this.userId,
    required this.name,
    required this.date,
    required this.amount,
    required this.category,
    required this.description,
  });
}