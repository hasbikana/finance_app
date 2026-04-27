import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/storage_service.dart';

class AuthService {
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/user/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = _extractToken(response.data);

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan dari API.');
      }

      await StorageService.saveToken(token);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Login gagal. Silakan coba lagi.');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/user',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final token = _extractToken(response.data);

      if (token != null && token.isNotEmpty) {
        await StorageService.saveToken(token);
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Registrasi gagal. Silakan coba lagi.');
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
      final response = await ApiClient.dio.get('/user');

      if (response.data is Map<String, dynamic>) {
        return response.data;
      }

      throw Exception('Format profile tidak valid.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Gagal mengambil data profile.');
    }
  }

  String? _extractToken(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final token = data['token'] ??
        data['access_token'] ??
        data['data']?['token'] ??
        data['data']?['access_token'];

    return token?.toString();
  }

  String _handleDioError(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }

      if (data['errors'] != null) {
        final errors = data['errors'];

        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;

          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }

          return firstError.toString();
        }
      }
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Koneksi terlalu lama. Periksa server Laravel Anda.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server API.';
    }

    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
  Future<Map<String, dynamic>> getProfile() async {
  try {
    final response = await ApiClient.dio.get('/user');
    final data = response.data['data']?['user'] ?? response.data['data'] ?? response.data;
    return Map<String, dynamic>.from(data);
  } on DioException catch (e) {
    throw Exception(_handleDioError(e));
  }
}

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      await ApiClient.dio.put(
        '/user/profile',
        data: {
          'name': name,
          'email': email,
        },
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await ApiClient.dio.put(
        '/user/password',
        data: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
}