import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/storage_service.dart';

class AuthService {
  Future<void> login({required String email, required String password}) async {
    try {
      final res = await ApiClient.dio.post('/user/login', data: {
        'email': email,
        'password': password,
      });
      final token = _extractToken(res.data);
      if (token == null || token.isEmpty) throw Exception('Token tidak ditemukan');
      await StorageService.saveToken(token);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await ApiClient.dio.post('/user', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.dio.post('/user/logout');
    } finally {
      await StorageService.clearToken();
    }
  }

  Future<Map<String, dynamic>> profile() async {
    try {
      final res = await ApiClient.dio.get('/user');
      return res.data is Map<String, dynamic> ? res.data : {};
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  String? _extractToken(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    return (data['token'] ?? data['access_token'] ?? data['data']?['token'] ?? data['data']?['access_token'])?.toString();
  }

  String _handleDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
          return first.toString();
        }
      }
    }
    if (e.type == DioExceptionType.connectionTimeout) return 'Koneksi timeout';
    if (e.type == DioExceptionType.connectionError) return 'Tidak dapat terhubung ke server';
    return 'Terjadi kesalahan';
  }
}