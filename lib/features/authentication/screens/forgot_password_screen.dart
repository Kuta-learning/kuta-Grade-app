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

/// Forgot Password screen designed to match the reference design specification.
/// Features a warm peach-to-blue background gradient, custom reset badge,
/// centered heading and instructions, white form card with email input,
/// "Send Instructions" CTA button, "Back to Login" action, and footer copyright mark.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendInstructions() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);

    try {
      final authBloc = context.read<AuthBloc>();
      await authBloc.authService.requestPasswordReset(email);

      if (!mounted) return;
      setState(() => _isLoading = false);

      AppSnackBar.showSuccess(
        context,
        'Verification code sent to $email.',
        title: 'Check Your Inbox',
      );

      // Navigate to OTP verification screen
      context.push(
        '${RouteNames.otpVerification}?email=${Uri.encodeComponent(email)}',
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.showError(context, e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.showError(
        context,
        'Could not send verification instructions. Please try again.',
      );
    }
  }

  void _handleBackToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.login);
    }
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
                    // 1. TOP RESET BADGE SQUIRCLE
                    // ==========================================
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEEE3), // Soft terracotta background
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock_reset,
                          size: 42,
                          color: Color(0xFF9D4300), // Deep terracotta / secondAccent
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==========================================
                    // 2. TITLE & SUBTITLE
                    // ==========================================
                    Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineLg.copyWith(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: AppColors.headlineDark,
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 310),
                      child: Text(
                        "No worries! Enter your school email address and we'll send you instructions to reset your password.",
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
                            // Label: Email Address
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Text(
                                'Email Address',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.authBrown,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Email Input Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleSendInstructions(),
                              autofillHints: const [AutofillHints.email],
                              style: AppTypography.bodyXl.copyWith(fontSize: 15),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!val.contains('@') || !val.contains('.')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.inputFill,
                                hintText: 'student@example.com',
                                hintStyle: AppTypography.bodyXl.copyWith(
                                  color: AppColors.inputPlaceholder,
                                  fontSize: 15,
                                ),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: Icon(
                                    AppIcons.email,
                                    color: AppColors.authIconBrown,
                                    size: 20,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 20,
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
                            ),

                            const SizedBox(height: 24),

                            // CTA: Send Instructions Button
                            _buildSendButton(),
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

  Widget _buildSendButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _handleSendInstructions,
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
                        'Send Instructions',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.surfaceWhite,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.send_outlined,
                        size: 18,
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
