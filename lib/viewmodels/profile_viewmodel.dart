import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _service = ProfileService();
  Map<String, dynamic>? profile;
  bool isLoading = true;
  String? error;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();
    try {
      profile = await _service.getProfile();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String name, String email) async {
    try {
      await _service.updateProfile(name: name, email: email);
      await loadProfile();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }

  Future<bool> updatePassword(String current, String newPass, String confirm) async {
    try {
      await _service.updatePassword(
        currentPassword: current,
        password: newPass,
        passwordConfirmation: confirm,
      );
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }
}