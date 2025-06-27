// lib/src/services/api_service.dart
import 'package:dio/dio.dart';
// UBAH: flutter_dotenv tidak lagi diperlukan di sini.

class ApiService {
  final Dio _dio;

  // Private constructor
  ApiService._() : _dio = Dio() {
    // Konfigurasi dasar untuk Dio
    _dio.options = BaseOptions(
      // --- PERUBAHAN UTAMA ADA DI SINI ---
      // Mengambil base URL dari variabel lingkungan yang di-inject saat build.
      // 'BASE_URL' harus sama dengan key yang ada di file .env.development & .env.production
      baseUrl: const String.fromEnvironment(
        'BASE_URL',
        // defaultValue digunakan saat menjalankan aplikasi dari IDE tanpa konfigurasi khusus.
        // Ini adalah fallback ke environment development.
        defaultValue: 'http://10.0.2.2:8080/api/',
      ),
      // ------------------------------------
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Menambahkan Interceptor untuk logging request dan response API di debug console.
    // Sangat berguna untuk debugging.
    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }

  // Singleton instance untuk memastikan hanya ada satu instance ApiService di seluruh aplikasi.
  static final ApiService _instance = ApiService._();

  // Factory constructor untuk menyediakan instance tunggal tersebut.
  factory ApiService() => _instance;

  /// Melakukan request GET ke sebuah [endpoint].
  ///
  /// [queryParameters] adalah map untuk query di URL (contoh: /books?page=1).
  Future<Response> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } on DioException {
      // Lemparkan kembali error agar bisa ditangani oleh AuthRepository atau lapisan di atasnya.
      rethrow;
    }
  }

  /// Melakukan request POST ke sebuah [endpoint] dengan [data] di body.
  Future<Response> post(
      String endpoint, {
        required Map<String, dynamic> data,
      }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException {
      rethrow;
    }
  }

  /// Melakukan request PUT ke sebuah [endpoint] dengan [data] di body.
  Future<Response> put(
      String endpoint, {
        required Map<String, dynamic> data,
      }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } on DioException {
      rethrow;
    }
  }

  /// Melakukan request DELETE ke sebuah [endpoint].
  Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } on DioException {
      rethrow;
    }
  }

  /// Method untuk menambahkan atau memperbarui token otentikasi di header.
  /// Panggil ini setelah user berhasil login.
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Method untuk menghapus token otentikasi dari header.
  /// Panggil ini saat user logout.
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}