import 'package:dio/dio.dart';
import '../core/api_client.dart';

class ProfileService {
  Future<Map<String, dynamic>> getProfile() async {
    final res = await ApiClient.dio.get('/user');
    final data = res.data['data']?['user'] ?? res.data['data'] ?? res.data;
    return Map<String, dynamic>.from(data);
  }

  Future<void> updateProfile({required String name, required String email}) async {
    await ApiClient.dio.put('/user/profile', data: {
      'name': name,
      'email': email,
    });
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await ApiClient.dio.put('/user/password', data: {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }
}