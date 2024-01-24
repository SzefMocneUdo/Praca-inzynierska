class CurrencyRate {
  String from;
  String to;
  String userId;

  CurrencyRate({required this.from, required this.to, required this.userId});

  Map<String, dynamic> toMap() {
    return {'from': from, 'to': to, 'userId': userId};
  }

  factory CurrencyRate.fromMap(Map<String, dynamic> map) {
    return CurrencyRate(
        from: map['from'], to: map['to'], userId: map['userId']);
  }
}
