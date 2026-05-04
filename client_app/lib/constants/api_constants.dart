class ApiConstants {
  static const String baseUrl = 'http://localhost:8080';

  // Auth endpoints
  static const String register = '$baseUrl/api/auth/register';
  static const String login = '$baseUrl/api/auth/login';

  // Employee endpoints
  static const String employees = '$baseUrl/api/employees';

  static String employeeById(int id) => '$employees/$id';
  static String employeesByDept(String dept) => '$employees/department/$dept';

  // Paginated endpoints
  static String employeesPaginated({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String sortDir = 'asc',
    String? search,
  }) {
    final params = <String>[
      'page=$page',
      'size=$size',
      'sortBy=$sortBy',
      'sortDir=$sortDir',
    ];
    if (search != null && search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search.trim())}');
    }
    return '$employees/page?${params.join('&')}';
  }

  // Export endpoints
  static const String exportCsv = '$employees/export/csv';
  static const String exportExcel = '$employees/export/excel';
}
