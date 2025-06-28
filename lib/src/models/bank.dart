// lib/src/models/bank_model.dart

class Bank {
  final int bankId;
  final String bankName;
  final String bankCode;

  Bank({
    required this.bankId,
    required this.bankName,
    required this.bankCode,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      bankId: json['bankId'] as int,
      bankName: json['bankName'] as String,
      bankCode: json['bankCode'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Bank && runtimeType == other.runtimeType && bankId == other.bankId;

  @override
  int get hashCode => bankId.hashCode;

  // Method ini akan dipanggil oleh dropdown_flutter untuk menampilkan nama bank
  @override
  String toString() {
    return bankName;
  }
// --------------------
}