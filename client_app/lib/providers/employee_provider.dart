import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../models/employee.dart';

import '../services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _service = EmployeeService();

  // Data
  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Pagination state
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalElements = 0;
  int _totalPages = 0;
  bool _isFirst = true;
  bool _isLast = true;

  // Sort state
  String _sortBy = 'id';
  String _sortDir = 'asc';

  // Search state
  String _searchQuery = '';

  // Export state
  bool _isExporting = false;

  // Getters
  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalElements => _totalElements;
  int get totalPages => _totalPages;
  bool get isFirst => _isFirst;
  bool get isLast => _isLast;
  String get sortBy => _sortBy;
  String get sortDir => _sortDir;
  String get searchQuery => _searchQuery;
  bool get isExporting => _isExporting;

  /// Fetch employees with server-side pagination
  Future<void> fetchEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getEmployeesPaginated(
        page: _currentPage,
        size: _pageSize,
        sortBy: _sortBy,
        sortDir: _sortDir,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      _isLoading = false;

      if (response.success) {
        _employees = response.data;
        _currentPage = response.pageNumber;
        _pageSize = response.pageSize;
        _totalElements = response.totalElements;
        _totalPages = response.totalPages;
        _isFirst = response.first;
        _isLast = response.last;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load employees. Check server connection.';
    }

    notifyListeners();
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page < 0 || page >= _totalPages) return;
    _currentPage = page;
    fetchEmployees();
  }

  /// Next page
  void nextPage() {
    if (!_isLast) goToPage(_currentPage + 1);
  }

  /// Previous page
  void previousPage() {
    if (!_isFirst) goToPage(_currentPage - 1);
  }

  /// Change page size
  void changePageSize(int size) {
    _pageSize = size;
    _currentPage = 0; // Reset to first page
    fetchEmployees();
  }

  /// Update sort
  void updateSort(String field) {
    if (_sortBy == field) {
      // Toggle direction
      _sortDir = _sortDir == 'asc' ? 'desc' : 'asc';
    } else {
      _sortBy = field;
      _sortDir = 'asc';
    }
    _currentPage = 0;
    fetchEmployees();
  }

  /// Update search query
  void updateSearch(String query) {
    _searchQuery = query;
    _currentPage = 0;
    fetchEmployees();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _currentPage = 0;
    fetchEmployees();
  }

  /// Export data — triggers a browser file download
  Future<void> exportData(String type) async {
    _isExporting = true;
    notifyListeners();

    try {
      final response = await _service.downloadExport(type);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final extension = type == 'csv' ? 'csv' : 'xlsx';
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'employees.$extension')
          ..style.display = 'none';
        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);
        _successMessage = '${type.toUpperCase()} file downloaded successfully!';
      } else {
        _errorMessage = 'Failed to download $type file.';
      }
    } catch (e) {
      _errorMessage = 'Export failed. Check server connection.';
    }

    _isExporting = false;
    notifyListeners();
  }

  /// Create employee
  Future<bool> createEmployee(Employee employee) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _service.createEmployee(employee);
      _isLoading = false;

      if (response.success) {
        _successMessage = 'Employee created successfully!';
        await fetchEmployees();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create employee.';
      notifyListeners();
      return false;
    }
  }

  /// Update employee
  Future<bool> updateEmployee(int id, Employee employee) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _service.updateEmployee(id, employee);
      _isLoading = false;

      if (response.success) {
        _successMessage = 'Employee updated successfully!';
        await fetchEmployees();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update employee.';
      notifyListeners();
      return false;
    }
  }

  /// Delete employee
  Future<bool> deleteEmployee(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.deleteEmployee(id);
      _isLoading = false;

      if (response.success) {
        _successMessage = 'Employee deleted successfully!';
        // If current page becomes empty after delete, go to previous page
        if (_employees.length == 1 && _currentPage > 0) {
          _currentPage--;
        }
        await fetchEmployees();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete employee.';
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
