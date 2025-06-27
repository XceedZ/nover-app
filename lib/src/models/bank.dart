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
      bankId: json['bank_id'] as int,
      bankName: json['bank_name'] as String,
      bankCode: json['bank_code'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Bank && runtimeType == other.runtimeType && bankId == other.bankId;

  @override
  int get hashCode => bankId.hashCode;

  // --- TAMBAHKAN INI ---
  // Method ini akan dipanggil oleh dropdown_flutter untuk menampilkan nama bank
  @override
  String toString() {
    return bankName;
  }
// --------------------
}