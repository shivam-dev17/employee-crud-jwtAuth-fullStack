import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/employee.dart';
import '../providers/auth_provider.dart';
import '../providers/employee_provider.dart';
import 'employee_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchEmployees();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<EmployeeProvider>().updateSearch(val);
    });
  }

  void _confirmDelete(Employee emp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Delete ${emp.firstName} ${emp.lastName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<EmployeeProvider>().deleteEmployee(emp.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExportMenu() {
    final prov = context.read<EmployeeProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Export Employee Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _exportButton('CSV', Icons.description_outlined, AppTheme.accent, () {
                  Navigator.pop(context);
                  prov.exportData('csv');
                })),
                const SizedBox(width: 16),
                Expanded(child: _exportButton('Excel', Icons.table_chart_outlined, AppTheme.info, () {
                  Navigator.pop(context);
                  prov.exportData('excel');
                })),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _exportButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.radiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppTheme.radiusMd,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prov = context.watch<EmployeeProvider>();
    final isWide = MediaQuery.of(context).size.width > 800;

    // Show snackbar for messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (prov.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(prov.successMessage!),
          backgroundColor: AppTheme.success,
        ));
        prov.clearMessages();
      }
    });

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(auth, prov),
          _buildStatsRow(prov),
          Expanded(
            child: prov.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : prov.errorMessage != null
                    ? _buildError(prov)
                    : prov.employees.isEmpty
                        ? _buildEmpty()
                        : isWide
                            ? _buildDataTable(prov)
                            : _buildCardList(prov),
          ),
          if (!prov.isLoading && prov.errorMessage == null) _buildPaginationBar(prov),
        ],
      ),
    );
  }

  Widget _buildAppBar(AuthProvider auth, EmployeeProvider prov) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(bottom: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: AppTheme.radiusMd),
            child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Employee Dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text('Welcome, ${auth.username ?? 'User'}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          ]),
          const Spacer(),
         ElevatedButton.icon(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EmployeeFormScreen()),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primary, // Sets the background color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Optional: rounds the corners
    ),
  ),
  icon: const Icon(Icons.add, color: Colors.white),
  label: const Text(
    'Add Employee',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
),
          // Search
          SizedBox(
            width: 280, height: 42,
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18), onPressed: () {
                          _searchCtrl.clear();
                          prov.clearSearch();
                        })
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                fillColor: AppTheme.bgSurface,
                border: OutlineInputBorder(borderRadius: AppTheme.radiusMd, borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Export button
          _iconBtn(Icons.download_rounded, AppTheme.accent, 'Export', _showExportMenu,
              loading: prov.isExporting),
          const SizedBox(width: 4),
          _iconBtn(Icons.refresh_rounded, AppTheme.textSecondary, 'Refresh', () => prov.fetchEmployees()),
          const SizedBox(width: 4),
          _iconBtn(Icons.logout_rounded, AppTheme.error, 'Logout', () {
            auth.logout();
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, String tooltip, VoidCallback onTap, {bool loading = false}) {
    return IconButton(
      onPressed: loading ? null : onTap,
      icon: loading
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: color))
          : Icon(icon, color: color),
      tooltip: tooltip,
    );
  }

  Widget _buildStatsRow(EmployeeProvider prov) {
    final depts = <String>{};
    for (final e in prov.employees) {
      if (e.department != null) depts.add(e.department!);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(children: [
        _statCard('Total Records', '${prov.totalElements}', Icons.groups_rounded, AppTheme.primary),
        const SizedBox(width: 16),
        _statCard('Page', '${prov.currentPage + 1} / ${prov.totalPages}', Icons.pages_rounded, AppTheme.accent),
        const SizedBox(width: 16),
        _statCard('Showing', '${prov.employees.length} of ${prov.totalElements}',
            Icons.visibility_rounded, AppTheme.warning),
      ]),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.bgCard, borderRadius: AppTheme.radiusMd,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: AppTheme.radiusSm),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildPaginationBar(EmployeeProvider prov) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(top: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          // Page size selector
          const Text('Rows: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: AppTheme.radiusSm),
            child: DropdownButton<int>(
              value: prov.pageSize,
              dropdownColor: AppTheme.bgCardLight,
              underline: const SizedBox(),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              items: [5, 10, 20, 50].map((s) => DropdownMenuItem(value: s, child: Text('$s'))).toList(),
              onChanged: (v) { if (v != null) prov.changePageSize(v); },
            ),
          ),
          const Spacer(),
          // Page info
          Text(
            '${prov.currentPage * prov.pageSize + 1}'
            '–${(prov.currentPage * prov.pageSize + prov.employees.length).clamp(0, prov.totalElements)}'
            ' of ${prov.totalElements}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 16),
          // Page buttons
          _pageBtn(Icons.first_page, prov.isFirst ? null : () => prov.goToPage(0)),
          _pageBtn(Icons.chevron_left, prov.isFirst ? null : () => prov.previousPage()),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: AppTheme.radiusSm),
            child: Text('${prov.currentPage + 1}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          _pageBtn(Icons.chevron_right, prov.isLast ? null : () => prov.nextPage()),
          _pageBtn(Icons.last_page, prov.isLast ? null : () => prov.goToPage(prov.totalPages - 1)),
        ],
      ),
    );
  }

  Widget _pageBtn(IconData icon, VoidCallback? onTap) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.radiusSm,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: disabled ? AppTheme.bgSurface : AppTheme.primary.withValues(alpha: 0.15),
          borderRadius: AppTheme.radiusSm,
        ),
        child: Icon(icon, size: 20, color: disabled ? AppTheme.textMuted : AppTheme.primary),
      ),
    );
  }

  Widget _buildError(EmployeeProvider prov) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
      const SizedBox(height: 16),
      Text(prov.errorMessage!, style: const TextStyle(color: AppTheme.textSecondary)),
      const SizedBox(height: 16),
      ElevatedButton.icon(onPressed: () => prov.fetchEmployees(), icon: const Icon(Icons.refresh), label: const Text('Retry')),
    ]));
  }

  Widget _buildEmpty() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inbox_rounded, size: 80, color: AppTheme.textMuted.withValues(alpha: 0.5)),
      const SizedBox(height: 16),
      const Text('No employees found', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
      const SizedBox(height: 8),
      const Text('Try a different search or add a new employee.', style: TextStyle(color: AppTheme.textMuted)),
    ]));
  }

  Widget _sortHeader(String label, String field, EmployeeProvider prov) {
    final isActive = prov.sortBy == field;
    final icon = !isActive ? Icons.unfold_more : (prov.sortDir == 'asc' ? Icons.arrow_upward : Icons.arrow_downward);
    return InkWell(
      onTap: () => prov.updateSort(field),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isActive ? AppTheme.primary : AppTheme.textSecondary,
        )),
        const SizedBox(width: 4),
        Icon(icon, size: 14, color: isActive ? AppTheme.primary : AppTheme.textMuted),
      ]),
    );
  }

  Widget _buildDataTable(EmployeeProvider prov) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.bgCard, borderRadius: AppTheme.radiusMd,
          border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.1)),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppTheme.bgCardLight),
          dataRowMinHeight: 56, dataRowMaxHeight: 56,
          columnSpacing: 24, horizontalMargin: 20,
          columns: [
            DataColumn(label: _sortHeader('ID', 'id', prov)),
            DataColumn(label: _sortHeader('Name', 'firstName', prov)),
            DataColumn(label: _sortHeader('Email', 'email', prov)),
            DataColumn(label: _sortHeader('Department', 'department', prov)),
            DataColumn(label: _sortHeader('Designation', 'designation', prov)),
            DataColumn(label: _sortHeader('Salary', 'salary', prov)),
            const DataColumn(label: Text('Actions',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
          ],
          rows: prov.employees.map((emp) => DataRow(cells: [
            DataCell(Text('${emp.id}', style: const TextStyle(color: AppTheme.textMuted))),
            DataCell(Row(children: [
              CircleAvatar(radius: 16, backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                child: Text(emp.firstName[0].toUpperCase(),
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13))),
              const SizedBox(width: 10),
              Text('${emp.firstName} ${emp.lastName}',
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
            ])),
            DataCell(Text(emp.email, style: const TextStyle(color: AppTheme.textSecondary))),
            DataCell(_deptChip(emp.department ?? '-')),
            DataCell(Text(emp.designation ?? '-', style: const TextStyle(color: AppTheme.textSecondary))),
            DataCell(Text(emp.salary != null ? '₹${emp.salary!.toStringAsFixed(0)}' : '-',
                style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600))),
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
              _actionBtn(Icons.edit_outlined, AppTheme.info, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeeFormScreen(employee: emp)));
              }),
              const SizedBox(width: 4),
              _actionBtn(Icons.delete_outline, AppTheme.error, () => _confirmDelete(emp)),
            ])),
          ])).toList(),
        ),
      ),
    );
  }

  Widget _deptChip(String dept) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: AppTheme.radiusSm),
      child: Text(dept, style: const TextStyle(color: AppTheme.primaryLight, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, borderRadius: AppTheme.radiusSm,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppTheme.radiusSm),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildCardList(EmployeeProvider prov) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prov.employees.length,
      itemBuilder: (ctx, i) {
        final emp = prov.employees[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                  child: Text(emp.firstName[0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${emp.firstName} ${emp.lastName}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  Text(emp.email, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                ])),
                _actionBtn(Icons.edit_outlined, AppTheme.info, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeeFormScreen(employee: emp)));
                }),
                const SizedBox(width: 8),
                _actionBtn(Icons.delete_outline, AppTheme.error, () => _confirmDelete(emp)),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _infoChip(Icons.business, emp.department ?? '-'),
                _infoChip(Icons.badge, emp.designation ?? '-'),
                _infoChip(Icons.currency_rupee, emp.salary != null ? '₹${emp.salary!.toStringAsFixed(0)}' : '-'),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: AppTheme.radiusSm),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ]),
    );
  }
}
