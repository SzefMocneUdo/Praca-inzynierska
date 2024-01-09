class CurrencyRate {
  String from;
  double to;
  String userId;

  CurrencyRate({required this.from, required this.to, required this.userId});

  // Converting to Map format for SharedPreferences or Local Storage
  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'userId': userId
    };
  }

  // Creating CurrencyRate from map
  factory CurrencyRate.fromMap(Map<String, dynamic> map) {
    return CurrencyRate(
      from: map['from'],
      to: map['to'],
      userId: map['userId']
    );
  }
}
