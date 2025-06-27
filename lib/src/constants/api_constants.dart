// lib/src/constants/api_constants.dart

class ApiConstants {
  // Kunci untuk mengambil base URL dari file .env
  static const String baseUrlKey = 'BASE_URL';

  // Endpoint untuk Autentikasi (tanpa /v1)
  static const String loginEndpoint = 'auth/login';
  static const String registerEndpoint = 'auth/register';

  // Endpoint untuk fitur v1
  static const String getBanksEndpoint = 'v1/bank/get';

}