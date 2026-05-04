import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/employee.dart';
import '../providers/employee_provider.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _deptCtrl;
  late TextEditingController _designCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _hireDateCtrl;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  bool get isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _firstNameCtrl = TextEditingController(text: e?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: e?.lastName ?? '');
    _emailCtrl = TextEditingController(text: e?.email ?? '');
    _phoneCtrl = TextEditingController(text: e?.phoneNumber ?? '');
    _deptCtrl = TextEditingController(text: e?.department ?? '');
    _designCtrl = TextEditingController(text: e?.designation ?? '');
    _salaryCtrl = TextEditingController(
        text: e?.salary != null ? e!.salary!.toStringAsFixed(0) : '');
    _hireDateCtrl = TextEditingController(text: e?.hireDate ?? '');

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _deptCtrl.dispose();
    _designCtrl.dispose();
    _salaryCtrl.dispose();
    _hireDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              surface: AppTheme.bgCard,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _hireDateCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<EmployeeProvider>();

    final employee = Employee(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      department: _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
      designation: _designCtrl.text.trim().isEmpty ? null : _designCtrl.text.trim(),
      salary: _salaryCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_salaryCtrl.text.trim()),
      hireDate: _hireDateCtrl.text.trim().isEmpty ? null : _hireDateCtrl.text.trim(),
    );

    bool success;
    if (isEditing) {
      success = await provider.updateEmployee(widget.employee!.id!, employee);
    } else {
      success = await provider.createEmployee(employee);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Employee updated successfully!'
              : 'Employee created successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              border: Border(
                bottom: BorderSide(
                    color: AppTheme.textMuted.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: AppTheme.textPrimary),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isEditing
                        ? AppTheme.accentGradient
                        : AppTheme.primaryGradient,
                    borderRadius: AppTheme.radiusMd,
                  ),
                  child: Icon(
                    isEditing ? Icons.edit_rounded : Icons.person_add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  isEditing ? 'Edit Employee' : 'Add New Employee',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Personal Info Section
                          _sectionHeader('Personal Information', Icons.person),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  controller: _firstNameCtrl,
                                  label: 'First Name',
                                  icon: Icons.person_outline,
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _field(
                                  controller: _lastNameCtrl,
                                  label: 'Last Name',
                                  icon: Icons.person_outline,
                                  required: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  controller: _emailCtrl,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  required: true,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(v)) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _field(
                                  controller: _phoneCtrl,
                                  label: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Work Info Section
                          _sectionHeader('Work Information', Icons.work),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  controller: _deptCtrl,
                                  label: 'Department',
                                  icon: Icons.business_outlined,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _field(
                                  controller: _designCtrl,
                                  label: 'Designation',
                                  icon: Icons.badge_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  controller: _salaryCtrl,
                                  label: 'Salary',
                                  icon: Icons.currency_rupee,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _pickDate,
                                  child: AbsorbPointer(
                                    child: _field(
                                      controller: _hireDateCtrl,
                                      label: 'Hire Date',
                                      icon: Icons.calendar_today_outlined,
                                      hint: 'YYYY-MM-DD',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Submit
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed:
                                        provider.isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isEditing
                                          ? AppTheme.accent
                                          : AppTheme.primary,
                                    ),
                                    child: provider.isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            isEditing
                                                ? 'Update Employee'
                                                : 'Create Employee',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(color: AppTheme.textMuted.withValues(alpha: 0.2)),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: validator ??
          (required
              ? (v) => v == null || v.isEmpty ? '$label is required' : null
              : null),
    );
  }
}
