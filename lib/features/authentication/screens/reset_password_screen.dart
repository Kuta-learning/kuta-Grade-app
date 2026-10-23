import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../services/auth_service.dart';

/// Screen allowing the user to enter and confirm their new password
/// after successfully verifying their OTP.
class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final authBloc = context.read<AuthBloc>();
      await authBloc.authService.resetPassword(
        email: widget.email,
        resetToken: widget.resetToken,
        newPassword: _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      AppSnackBar.showSuccess(
        context,
        'Your password has been reset successfully! Please log in.',
        title: 'Password Updated',
      );

      // Navigate back to login
      context.go(RouteNames.login);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.showError(context, e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.showError(context, 'Failed to update password. Please try again.');
    }
  }

  void _handleBackToLogin() {
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAF1E8), // Warm soft peach / cream
              Color(0xFFEFF5FC), // Soft sky blue
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),

                    // ==========================================
                    // 1. TOP BADGE SQUIRCLE
                    // ==========================================
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEEE3),
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 42,
                          color: Color(0xFF9D4300),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==========================================
                    // 2. TITLE & SUBTITLE
                    // ==========================================
                    Text(
                      'Create New Password',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineLg.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.headlineDark,
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        'Your new password must be at least 8 characters long.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.authBrown,
                          fontSize: 14.5,
                          height: 1.45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==========================================
                    // 3. WHITE FORM CARD
                    // ==========================================
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Label: New Password
                            _buildLabel('New Password'),
                            const SizedBox(height: 8),
                            _buildPasswordField(
                              controller: _passwordController,
                              isObscured: _obscurePassword,
                              onToggleObscure: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter a new password';
                                }
                                if (val.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // Label: Confirm Password
                            _buildLabel('Confirm Password'),
                            const SizedBox(height: 8),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              isObscured: _obscureConfirmPassword,
                              onToggleObscure: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please confirm your new password';
                                }
                                if (val != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // CTA: Reset Password Button
                            _buildSubmitButton(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==========================================
                    // 4. BACK TO LOGIN LINK
                    // ==========================================
                    GestureDetector(
                      onTap: _handleBackToLogin,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_back_rounded,
                            size: 18,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Back to Login',
                            style: AppTypography.labelMdSemiBold.copyWith(
                              color: const Color(0xFF2563EB),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ==========================================
                    // 5. FOOTER COPYRIGHT
                    // ==========================================
                    Text(
                      '© 2024 Kuta Learning. All rights reserved.',
                      textAlign: TextAlign.center,
                      style: AppTypography.captionSm.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Text(
        text,
        style: AppTypography.labelMd.copyWith(
          color: AppColors.authBrown,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggleObscure,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      textInputAction: TextInputAction.done,
      style: AppTypography.bodyXl.copyWith(fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputFill,
        hintText: '••••••••',
        hintStyle: AppTypography.bodyXl.copyWith(
          color: AppColors.inputPlaceholder,
          fontSize: 15,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Icon(
            AppIcons.lock,
            color: AppColors.authIconBrown,
            size: 20,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? AppIcons.visibility : AppIcons.visibilityOff,
            color: AppColors.authBrown,
            size: 20,
          ),
          onPressed: onToggleObscure,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.mainAccent,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _handleResetPassword,
        borderRadius: BorderRadius.circular(9999),
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            color: _isLoading
                ? AppColors.orange500.withValues(alpha: 0.7)
                : AppColors.orange500,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(249, 115, 22, 0.25),
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.surfaceWhite,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Reset Password',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.surfaceWhite,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: AppColors.surfaceWhite,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
