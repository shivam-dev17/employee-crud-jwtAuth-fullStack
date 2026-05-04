import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/employee.dart';
import '../models/api_response.dart';
import '../models/paginated_response.dart';
import 'auth_service.dart';

class EmployeeService {
  final AuthService _authService = AuthService();

  /// Create a new employee
  Future<ApiResponse<Employee>> createEmployee(Employee employee) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.employees),
      headers: headers,
      body: jsonEncode(employee.toJson()),
    );

    return _handleResponse(response);
  }

  /// Get all employees
  Future<ApiResponse<List<Employee>>> getAllEmployees() async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.employees),
      headers: headers,
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 401) {
      return ApiResponse<List<Employee>>(
        success: false,
        message: 'Unauthorized. Please login again.',
      );
    }

    return ApiResponse<List<Employee>>.fromJson(
      json,
      (data) => (data as List).map((e) => Employee.fromJson(e)).toList(),
    );
  }

  /// Get paginated employees with optional search
  Future<PaginatedResponse<Employee>> getEmployeesPaginated({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String sortDir = 'asc',
    String? search,
  }) async {
    final headers = await _authService.getAuthHeaders();
    final url = ApiConstants.employeesPaginated(
      page: page,
      size: size,
      sortBy: sortBy,
      sortDir: sortDir,
      search: search,
    );

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 401) {
      return PaginatedResponse<Employee>(
        success: false,
        message: 'Unauthorized. Please login again.',
        data: [],
        pageNumber: 0,
        pageSize: size,
        totalElements: 0,
        totalPages: 0,
        first: true,
        last: true,
      );
    }

    final json = jsonDecode(response.body);
    return PaginatedResponse<Employee>.fromJson(
      json,
      (item) => Employee.fromJson(item),
    );
  }

  /// Get employee by ID
  Future<ApiResponse<Employee>> getEmployeeById(int id) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.employeeById(id)),
      headers: headers,
    );

    return _handleResponse(response);
  }

  /// Update employee
  Future<ApiResponse<Employee>> updateEmployee(int id, Employee employee) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.put(
      Uri.parse(ApiConstants.employeeById(id)),
      headers: headers,
      body: jsonEncode(employee.toJson()),
    );

    return _handleResponse(response);
  }

  /// Delete employee
  Future<ApiResponse> deleteEmployee(int id) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.delete(
      Uri.parse(ApiConstants.employeeById(id)),
      headers: headers,
    );

    final json = jsonDecode(response.body);
    return ApiResponse.fromJson(json, null);
  }

  /// Get employees by department
  Future<ApiResponse<List<Employee>>> getByDepartment(String dept) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.employeesByDept(dept)),
      headers: headers,
    );

    final json = jsonDecode(response.body);
    return ApiResponse<List<Employee>>.fromJson(
      json,
      (data) => (data as List).map((e) => Employee.fromJson(e)).toList(),
    );
  }

  /// Download export file (CSV or Excel) and return raw bytes
  Future<http.Response> downloadExport(String type) async {
    final headers = await _authService.getAuthHeaders();
    // Remove Content-Type for download request; server returns binary
    headers.remove('Content-Type');

    final url = type == 'csv'
        ? ApiConstants.exportCsv
        : ApiConstants.exportExcel;

    return await http.get(Uri.parse(url), headers: headers);
  }

  ApiResponse<Employee> _handleResponse(http.Response response) {
    final json = jsonDecode(response.body);

    if (response.statusCode == 401) {
      return ApiResponse<Employee>(
        success: false,
        message: 'Unauthorized. Please login again.',
      );
    }

    return ApiResponse<Employee>.fromJson(
      json,
      (data) => Employee.fromJson(data),
    );
  }
}
