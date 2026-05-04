import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/api_response.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _usernameKey = 'username';
  static const String _roleKey = 'role';

  /// Register a new user
  Future<ApiResponse> register(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final json = jsonDecode(response.body);
    return ApiResponse.fromJson(json, null);
  }

  /// Login and receive JWT token
  Future<ApiResponse<AuthData>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final json = jsonDecode(response.body);
    final apiResponse = ApiResponse<AuthData>.fromJson(
      json,
      (data) => AuthData.fromJson(data),
    );

    if (apiResponse.success && apiResponse.data != null) {
      await _saveAuth(apiResponse.data!);
    }

    return apiResponse;
  }

  /// Save authentication data locally
  Future<void> _saveAuth(AuthData auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, auth.token);
    await prefs.setString(_usernameKey, auth.username);
    await prefs.setString(_roleKey, auth.role);
  }

  /// Get saved JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get saved username
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout - clear saved data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_roleKey);
  }

  /// Get authorization headers
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
