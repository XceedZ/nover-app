class CoinTransaction {
  final int transactionId;
  final String transactionType;
  final String coinType;
  final int amount;
  final String? description;
  final String? expiryDate;
  final String createDatetime;

  CoinTransaction({
    required this.transactionId,
    required this.transactionType,
    required this.coinType,
    required this.amount,
    this.description,
    this.expiryDate,
    required this.createDatetime,
  });

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      transactionId: json['transactionId'],
      transactionType: json['transactionType'],
      coinType: json['coinType'],
      amount: json['amount'],
      description: json['description'],
      expiryDate: json['expiryDate'],
      createDatetime: json['createDatetime'],
    );
  }
}