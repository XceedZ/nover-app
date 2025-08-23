// lib/src/repositories/notification_repository.dart
import 'package:dio/dio.dart';
import 'package:nover/src/constants/api_constants.dart';
import 'package:nover/src/models/notification_item.dart';
import 'package:nover/src/services/api_service.dart';
import 'dart:developer' as developer;

class NotificationRepository {
  final ApiService _apiService = ApiService();

  Future<PaginatedNotificationResponse> getNotifications({int page = 1}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.getNotificationsEndpoint,
        queryParameters: {'page': page, 'limit': 20}, // Kita ambil 20 per halaman
      );
      return PaginatedNotificationResponse.fromJson(response.data);
    } on DioException {
      throw Exception('Failed to connect to the server.');
    } catch (e) {
      developer.log('Unexpected error fetching notifications: $e', name: 'NotificationRepository');
      throw Exception('An unexpected error occurred.');
    }
  }
}