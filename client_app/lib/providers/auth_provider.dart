import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _username;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get errorMessage => _errorMessage;

  /// Check initial auth state
  Future<void> checkAuth() async {
    _isLoggedIn = await _authService.isLoggedIn();
    _username = await _authService.getUsername();
    notifyListeners();
  }

  /// Register a new user
  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(username, password);
      _isLoading = false;

      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Connection error. Is the server running?';
      notifyListeners();
      return false;
    }
  }

  /// Login user
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);
      _isLoading = false;

      if (response.success && response.data != null) {
        _isLoggedIn = true;
        _username = response.data!.username;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Connection error. Is the server running?';
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _username = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
