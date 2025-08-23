import 'package:dio/dio.dart';
import 'package:nover/src/constants/api_constants.dart';
import 'package:nover/src/models/event_center_data.dart';
import 'package:nover/src/services/api_service.dart';
import 'package:nover/src/utils/translation.dart';
import 'dart:developer' as developer;

class EventRepository {
  final ApiService _apiService = ApiService();

  Future<CheckinStatus> getCheckinStatus() async {
    try {
      final response = await _apiService.get(ApiConstants.getCheckinStatusEndpoint);
      return CheckinStatus.fromJson(response.data);
    } on DioException {
      throw Exception('Failed to connect to the server.');
    } catch (e) {
      developer.log('Error fetching checkin status: $e', name: 'EventRepository');
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<int> performCheckin() async {
    try {
      // ✨ PERBAIKAN: Tambahkan parameter `data` dengan map kosong
      final response = await _apiService.post(ApiConstants.performCheckinEndpoint, data: {});
      return response.data['reward'] as int;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        throw Exception(e.response!.data['message'] ?? 'Failed to check-in.');
      }
      throw Exception('Failed to connect to the server.');
    } catch (e) {
      developer.log('Error performing checkin: $e', name: 'EventRepository');
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<List<MissionStatus>> getMissions() async {
    try {
      final response = await _apiService.get(ApiConstants.getDailyMissionsEndpoint);
      final List<dynamic> data = response.data;
      return data.map((json) => MissionStatus.fromJson(json)).toList();
    } on DioException {
      throw Exception('Failed to connect to the server.');
    } catch (e) {
      developer.log('Error fetching missions: $e', name: 'EventRepository');
      throw Exception('An unexpected error occurred.');
    }
  }
}