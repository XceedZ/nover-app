import 'dart:core';

class DicebearRepository {
  // Base URL untuk DiceBear Avatars. Static dan const agar efisien.
  static const String _baseUrl = 'https://api.dicebear.com/9.x/initials/svg';

  // Parameter styling default yang Anda berikan. Bisa diubah di sini jika perlu.
  static const String _defaultParams =
      '&backgroundColor=00897b,00acc1,039be5,1e88e5,3949ab,43a047,5e35b1,8e24aa'
      '&backgroundType=gradientLinear,solid'
      '&fontFamily=sans-serif,Arial'
      '&chars=1';

  /// Menghasilkan URL avatar dari DiceBear berdasarkan [seed].
  /// [seed] biasanya adalah nama pengguna untuk menghasilkan inisial yang konsisten.
  String getAvatarUrl(String seed) {
    // Meng-encode seed untuk memastikan karakter seperti spasi aman untuk URL.
    final encodedSeed = Uri.encodeComponent(seed);

    // Menggabungkan semua bagian untuk membuat URL lengkap.
    return '$_baseUrl?seed=$encodedSeed$_defaultParams';
  }
}