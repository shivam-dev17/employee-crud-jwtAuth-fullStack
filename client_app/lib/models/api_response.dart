class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? timestamp;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : json['data'],
      timestamp: json['timestamp'],
    );
  }
}

class AuthData {
  final String token;
  final String tokenType;
  final String username;
  final String role;

  AuthData({
    required this.token,
    required this.tokenType,
    required this.username,
    required this.role,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
