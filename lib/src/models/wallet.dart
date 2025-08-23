class Wallet {
  final int userId;
  final int paidCoins;
  final int bonusCoins;

  Wallet({
    required this.userId,
    required this.paidCoins,
    required this.bonusCoins,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      userId: json['userId'] ?? 0,
      paidCoins: json['paidCoins'] ?? 0,
      bonusCoins: json['bonusCoins'] ?? 0,
    );
  }

  // Getter untuk total koin agar lebih mudah
  int get totalCoins => paidCoins + bonusCoins;
}