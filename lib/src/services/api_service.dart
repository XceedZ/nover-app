// lib/src/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:nover/src/constants/api_constants.dart';
import 'package:nover/src/services/logout_service.dart'; // Import layanan logout

class ApiService {
  final Dio _dio;

  ApiService._() : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: const String.fromEnvironment(
        'BASE_URL',
        defaultValue: 'http://10.0.2.2:8080/api/',
      ),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // --- INTERCEPTOR UNTUK MENANGANI ERROR 401 SECARA GLOBAL ---
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, handler) async {
          // Periksa apakah error adalah response dari server dengan status code 401.
          if (err.response?.statusCode == 401) {
            // Jika ya, panggil layanan logout.
            await LogoutService.perform();

            // Kita bisa hentikan error di sini agar tidak memicu notifikasi Snackify
            // karena aplikasi sudah akan berpindah halaman.
            // Cukup kembalikan response dummy untuk menyelesaikan rantai promise.
            return handler.resolve(Response(requestOptions: err.requestOptions, data: 'Logged out due to 401'));
          }
          // Jika error bukan 401, biarkan ia berlanjut untuk ditangani oleh repository.
          return handler.next(err);
        },
      ),
    );
    // -------------------------------------------------------------

    // Interceptor untuk logging tetap berguna untuk debugging.
    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }

  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;

  // ... sisa metode (get, post, put, delete) tidak ada perubahan ...
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(String endpoint, {required Map<String, dynamic> data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> put(String endpoint, {required Map<String, dynamic> data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } on DioException {
      rethrow;
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
