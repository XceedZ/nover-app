class ApiConstants {
  // Kunci untuk mengambil base URL dari file .env
  static const String baseUrlKey = 'BASE_URL';

  // Endpoint untuk Autentikasi
  static const String loginEndpoint = 'auth/login';
  static const String registerEndpoint = 'auth/register';
  static const String logoutEndpoint = 'auth/logout';

  // Endpoint untuk Fitur Lain (contoh)
  static const String getBooksEndpoint = 'books';
  static const String getUserProfileEndpoint = 'user/profile';
}