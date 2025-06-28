// lib/src/repositories/auth_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:nover/src/constants/api_constants.dart';
import 'package:nover/src/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/constants/constants.dart';
import 'dart:developer' as developer;

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  // UBAH 1: Pastikan tipe return-nya adalah Future<Map<String, dynamic>>
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final loginData = {'username': username, 'password': password};

    try {
      final response = await _apiService.post(
        ApiConstants.loginEndpoint,
        data: loginData,
      );

      if (response.statusCode == 200 && response.data != null) {

        // --- TAMBAHKAN BARIS INI UNTUK DEBUGGING ---
        developer.log('API Login Response Body: ${response.data}', name: 'AuthRepository');
        // -------------------------------------------

        final token = response.data['token'];
        final userData = response.data['user'];

        if (token != null && userData != null) {
          _apiService.setAuthToken(token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(tokenSessionKey, token);
          await prefs.setString(userSessionKey, jsonEncode(userData));

          return userData as Map<String, dynamic>;
        } else {
          throw 'Invalid response format from server.';
        }
      } else {
        throw te('unknownApi');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorCode = e.response!.data['code'];
        if (errorCode != null && errorCode is String) {
          throw te(errorCode);
        }
      }
      throw te('unknownApi');
    } catch (e) {
      throw te('unexpected');
    }
  }

  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    final registerData = {
      'fullName': fullName,
      'username': username,
      'email': email,
      'password': password,
    };

    try {
      // API registrasi biasanya mengembalikan status 201 Created atau 200 OK
      // dan tidak selalu mengembalikan token. Kita anggap sukses jika tidak ada error.
      await _apiService.post(
        ApiConstants.registerEndpoint,
        data: registerData,
      );
    } on DioException catch (e) {
      // Tangani error API seperti pada fungsi login
      if (e.response?.data != null && e.response!.data is Map) {
        final errorCode = e.response!.data['code'];
        if (errorCode != null && errorCode is String) {
          // Contoh error code dari API: 'email_already_exists', 'username_taken'
          throw te(errorCode);
        }
      }
      throw te('unknownApi');
    } catch (e) {
      throw te('unexpected');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenSessionKey);
    final userDataString = prefs.getString(userSessionKey);
    if (token != null && userDataString != null) {
      _apiService.setAuthToken(token);
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenSessionKey);
    await prefs.remove(userSessionKey);
    _apiService.clearAuthToken();
  }
}