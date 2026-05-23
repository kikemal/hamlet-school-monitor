import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_validator.dart';
import '../guards/role_guard.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_shell.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = AppConstants.roleParent;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _schoolIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    try {
      final profile = await ref.read(authProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            role: _selectedRole,
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            schoolId: _selectedRole == AppConstants.roleStudent
                ? _schoolIdController.text.trim()
                : null,
          );

      if (profile != null && mounted) {
        context.go(RoleGuard.dashboardRouteForRole(profile.role));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = authState.isLoading;

    return AuthShell(
      subtitle: 'Create your Hamlet School account',
      child: AuthFormCard(
        title: 'Create Account',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account type',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: InputDecoration(
                  fillColor:
                      isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                ),
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.roleParent,
                    child: Text('Parent'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.roleStudent,
                    child: Text('Student'),
                  ),
                ],
                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedRole = value);
                        }
                      },
              ),
              SizedBox(height: 16.h),
              _labeledField(
                label: 'First Name',
                child: TextFormField(
                  controller: _firstNameController,
                  validator: AppValidator.validateName,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(isDark, hint: 'Jane'),
                ),
              ),
              SizedBox(height: 16.h),
              _labeledField(
                label: 'Last Name',
                child: TextFormField(
                  controller: _lastNameController,
                  validator: AppValidator.validateName,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(isDark, hint: 'Doe'),
                ),
              ),
              SizedBox(height: 16.h),
              _labeledField(
                label: 'Email',
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidator.validateEmail,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(isDark, hint: 'you@school.com'),
                ),
              ),
              SizedBox(height: 16.h),
              _labeledField(
                label: 'Phone (optional)',
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(isDark, hint: '+255...'),
                ),
              ),
              if (_selectedRole == AppConstants.roleStudent) ...[
                SizedBox(height: 16.h),
                _labeledField(
                  label: 'School ID',
                  child: TextFormField(
                    controller: _schoolIdController,
                    validator: (v) =>
                        AppValidator.validateRequired(v, 'School ID'),
                    decoration: _inputDecoration(
                      isDark,
                      hint: 'UUID from your school admin',
                    ),
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              _labeledField(
                label: 'Password',
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: AppValidator.validatePassword,
                  decoration: _inputDecoration(isDark, hint: '••••••••').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _labeledField(
                label: 'Confirm Password',
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  validator: _validateConfirmPassword,
                  onFieldSubmitted: (_) => _handleRegister(),
                  decoration: _inputDecoration(isDark, hint: '••••••••').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 16.h),
                Text(
                  _errorMessage!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: isLoading ? null : AppColors.primaryGradient,
                    color: isLoading ? AppColors.textSecondaryLight : null,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 24.w,
                            width: 24.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: AppTypography.buttonText
                                .copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () => context.go(AppConstants.routeLogin),
                  child: Text(
                    'Already have an account? Sign In',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(bool isDark, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
    );
  }
}
