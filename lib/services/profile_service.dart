import '../core/api_client.dart';

class ProfileService {
  Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiClient.dio.get('/user');
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    await ApiClient.dio.put(
      '/user/profile',
      data: {
        'name': name,
        'email': email,
      },
    );
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await ApiClient.dio.put(
      '/user/password',
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }
}