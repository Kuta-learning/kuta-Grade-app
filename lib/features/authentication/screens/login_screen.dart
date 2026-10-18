import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/animated_auth_background.dart';

/// Unified Login Screen designed to match the reference design.
/// Features a sky-blue to warm-peach vertical gradient, an elevated white card,
/// accessible form inputs with icons, validation, authentication Bloc integration,
/// and responsive layout.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
          LoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _handleForgotPassword() {
    context.push(RouteNames.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${state.user.name}!'),
              backgroundColor: AppColors.success,
            ),
          );

          if (state.user.isKgStudent) {
            context.go(RouteNames.kgHome);
          } else {
            context.go(RouteNames.gradeDashboard);
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColors.surfaceApp,
            body: Stack(
              fit: StackFit.expand,
              children: [
                const AnimatedAuthBackground(),
                SafeArea(
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
                          // ==========================================
                          // MAIN WHITE CARD
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 32.0,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // --- Header Section ---
                                  Text(
                                    'Welcome Back',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.headlineLg.copyWith(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.headlineDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Continue your journey to mastery',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyLg.copyWith(
                                      color: AppColors.authBrown,
                                      fontSize: 14.5,
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // --- Email Field ---
                                  _buildLabel('Email Address'),
                                  const SizedBox(height: 8),
                                  _buildEmailInput(),

                                  const SizedBox(height: 18),

                                  // --- Password Field ---
                                  _buildLabel('Password'),
                                  const SizedBox(height: 8),
                                  _buildPasswordInput(),

                                  const SizedBox(height: 6),
                                  // Helper text below password
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0,
                                    ),
                                    child: Text(
                                      'Minimum 8 characters with a mix of letters and numbers.',
                                      style: AppTypography.captionSm.copyWith(
                                        color: AppColors.authBrown.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // --- Forgot Password Link ---
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: _handleForgotPassword,
                                      child: Text(
                                        'Forgot Password?',
                                        style: AppTypography.labelMdSemiBold
                                            .copyWith(
                                          color: const Color(0xFF2563EB),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // --- Login Button ---
                                  _buildLoginButton(isLoading: isLoading),

                                  const SizedBox(height: 24),

                                  // --- Divider Row: "or continue with" ---
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Divider(
                                          color: AppColors.borderVariant,
                                          height: 1,
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0,
                                        ),
                                        child: Text(
                                          'or continue with',
                                          style: AppTypography.labelMdMedium
                                              .copyWith(
                                            color: AppColors.authBrown
                                                .withValues(alpha: 0.75),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Divider(
                                          color: AppColors.borderVariant,
                                          height: 1,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // --- Sign in with Google Button ---
                                  _buildGoogleSignInButton(),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ==========================================
                          // FOOTER: Don't have an account? Sign up for free
                          // ==========================================
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.authBrown,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push(RouteNames.register),
                                child: Text(
                                  'Sign up for free',
                                  style: AppTypography.labelMdSemiBold.copyWith(
                                    color: const Color(0xFF2563EB),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
            ],
          ),
        );
        },
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

  Widget _buildEmailInput() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
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
          borderSide: const BorderSide(color: AppColors.mainAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      autofillHints: const [AutofillHints.password],
      style: AppTypography.bodyXl.copyWith(fontSize: 15),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please enter your password';
        }
        if (val.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
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
            _obscurePassword ? AppIcons.visibility : AppIcons.visibilityOff,
            color: AppColors.authBrown,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
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
          borderSide: const BorderSide(color: AppColors.mainAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildLoginButton({bool isLoading = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : _handleLogin,
        borderRadius: BorderRadius.circular(9999),
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            color: isLoading
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
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.surfaceWhite,
                    ),
                  )
                : Text(
                    'Login',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.surfaceWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign-In initiated...'),
              backgroundColor: AppColors.info,
            ),
          );
        },
        borderRadius: BorderRadius.circular(9999),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: AppColors.borderVariant, width: 1),
            boxShadow: AppElevation.elevation1,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppIcons.googleSvg, width: 20, height: 20),
              const SizedBox(width: 10),
              Text('Sign in with Google', style: AppTypography.labelMd),
            ],
          ),
        ),
      ),
    );
  }
}
