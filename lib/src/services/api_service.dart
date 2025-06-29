// lib/src/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:nover/src/constants/api_constants.dart';
import 'package:nover/src/services/logout_service.dart';

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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, handler) async {
          if (err.response?.statusCode == 401) {
            // Lakukan logout
            await LogoutService.perform();

            // UBAH: Jangan teruskan error 401. Buat response 'dummy' untuk
            // menghentikan rantai error di sini, karena navigasi sudah ditangani.
            // Ini akan mencegah 'catch' di repository dan UI dieksekusi untuk error 401.
            return handler.resolve(Response(
              requestOptions: err.requestOptions,
              data: {'message': 'Session expired and logged out.'},
              statusCode: 200, // Anggap sudah ditangani
            ));
          }
          // Jika error lain, teruskan seperti biasa
          return handler.next(err);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }

  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;

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

  Future<Response> patch(
      String endpoint, {
        Map<String, dynamic>? data,
      }) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
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
