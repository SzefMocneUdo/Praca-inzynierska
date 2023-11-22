class CurrencyRate {
  String from;
  double to;

  CurrencyRate({required this.from, required this.to});

  // Converting to Map format for SharedPreferences or Local Storage
  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
    };
  }

  // Creating CurrencyRate from map
  factory CurrencyRate.fromMap(Map<String, dynamic> map) {
    return CurrencyRate(
      from: map['from'],
      to: map['to'],
    );
  }
}
