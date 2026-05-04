class PaginatedResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final String? timestamp;

  PaginatedResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    this.timestamp,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    return PaginatedResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: rawData.map((e) => fromItem(e as Map<String, dynamic>)).toList(),
      pageNumber: json['pageNumber'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      totalElements: (json['totalElements'] ?? 0) is int
          ? json['totalElements']
          : (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      timestamp: json['timestamp'],
    );
  }
}
