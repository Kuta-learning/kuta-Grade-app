import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/grade_level.dart';
import '../../../core/router/route_names.dart';
import '../bloc/auth_bloc.dart';

/// Registration / Sign Up screen designed to match the Figma CSS specification.
/// Features atmospheric blur glows, glassmorphic registration card,
/// accessible form inputs, grade selector, and authentication navigation.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedGrade;
  GradeLevel? _selectedGradeLevel;
  bool _obscurePassword = true;

  /// Maps display labels shown in the dropdown to [GradeLevel] enum values.
  final Map<String, GradeLevel> _gradeLabelMap = {
    for (final g in GradeLevel.values) g.displayName: g,
  };

  List<String> get _gradeOptions => _gradeLabelMap.keys.toList();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedGradeLevel == null) return;

    context.read<AuthBloc>().add(
          RegisterRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            gradeLevel: _selectedGradeLevel!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // TODO: Navigate to onboarding or home once those screens exist
          // context.go(RouteNames.home);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${state.user.name}!'),
              backgroundColor: AppColors.success,
            ),
          );
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
        builder: (context, authState) {
          final isLoading = authState is AuthLoading;
          return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==========================================
          // 1. ATMOSPHERIC BACKGROUND GLOWS
          // ==========================================

          // Top-right Light Blue Glow (500x500 blur sphere)
          Positioned(
            top: -88.8,
            right: -39.0,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.orange500.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),

          // Bottom-left Orange Glow (400x400 blur sphere)
          Positioned(
            bottom: -88.8,
            left: -39.0,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glowBlue.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // 2. MAIN REGISTRATION CONTENT
          // ==========================================
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space8 + AppSpacing.space4, // 48px
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 358),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite.withValues(alpha: 0.95),
                      borderRadius: AppRadius.roundedXl,
                      border: Border.all(color: AppColors.borderVariant),
                      boxShadow: AppElevation.elevationLg,
                    ),
                    padding: AppSpacing.p6, // 24px padding
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- Header Section ---
                          Text(
                            'Create your account',
                            textAlign: TextAlign.center,
                            style: AppTypography.headlineLg.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Continue your journey to mastery',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.authBrown,
                            ),
                          ),

                          AppSpacing.vGap6, // 24px gap
                          // --- Field 1: Full Name ---
                          _buildLabel('Full Name'),
                          const SizedBox(height: 4),
                          _buildTextInput(
                            controller: _nameController,
                            hintText: 'John Doe',
                            prefixIcon: AppIcons.person,
                            keyboardType: TextInputType.name,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),

                          AppSpacing.vGap4, // 16px gap
                          // --- Field 2: Grade Level ---
                          _buildLabel('Grade'),
                          const SizedBox(height: 4),
                          _buildGradeDropdown(),

                          AppSpacing.vGap4, // 16px gap
                          // --- Field 3: Email Address ---
                          _buildLabel('Email Address'),
                          const SizedBox(height: 4),
                          _buildTextInput(
                            controller: _emailController,
                            hintText: 'student@example.com',
                            prefixIcon: AppIcons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),

                          AppSpacing.vGap4, // 16px gap
                          // --- Field 4: Password ---
                          _buildLabel('Password'),
                          const SizedBox(height: 4),
                          _buildPasswordInput(),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space1,
                            ),
                            child: Text(
                              'Minimum 8 characters with a mix of letters and numbers.',
                              style: AppTypography.captionSm,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // --- CTA: Sign Up Button ---
                          _buildSignUpButton(isLoading: isLoading),

                          const SizedBox(height: 16),

                          // --- Divider between Sign Up and Google ---
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
                                  horizontal: AppSpacing.space4,
                                ),
                                child: Text(
                                  'or',
                                  style: AppTypography.labelMdMedium.copyWith(
                                    color: AppColors.inputPlaceholder,
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

                          const SizedBox(height: 16),

                          // --- Sign Up with Google Button ---
                          _buildGoogleSignUpButton(),

                          AppSpacing.vGap6, // 24px gap
                          // --- Footer: Divider, Login Link & Trust Badge ---
                          const Divider(
                            color: AppColors.borderVariant,
                            height: 1,
                            thickness: 1,
                          ),

                          AppSpacing.vGap6, // 24px gap
                          // Already have an account? Login Screen
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppTypography.labelMdMedium.copyWith(
                                  color: AppColors.authBrown,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push(RouteNames.login),
                                child: Text(
                                  'Login',
                                  style: AppTypography.labelMdSemiBold,
                                ),
                              ),
                            ],
                          ),

                          AppSpacing.vGap4, // 16px gap
                          // SAFE & SECURE Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 1,
                                color: AppColors.borderVariant,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'SAFE & SECURE',
                                style: AppTypography.captionBold.copyWith(
                                  color: AppColors.authBrown.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 32,
                                height: 1,
                                color: AppColors.borderVariant,
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
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space1),
      child: Text(
        text,
        style: AppTypography.labelMd.copyWith(color: AppColors.authBrown),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.bodyXl,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputFill,
        hintText: hintText,
        hintStyle: AppTypography.bodyXl.copyWith(
          color: AppColors.inputPlaceholder,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(prefixIcon, color: AppColors.authIconBrown, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: const BorderSide(color: AppColors.mainAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildGradeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGrade,
      icon: const SizedBox.shrink(),
      style: AppTypography.bodyXl,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputFill,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            AppIcons.chevronDown,
            color: AppColors.authIconBrown,
            size: 18,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: const BorderSide(color: AppColors.mainAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      hint: Text(
        'Select your grade',
        style: AppTypography.bodyXl.copyWith(color: AppColors.inputPlaceholder),
      ),
      items: _gradeOptions.map((grade) {
        return DropdownMenuItem<String>(value: grade, child: Text(grade));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGrade = value;
          _selectedGradeLevel = value != null ? _gradeLabelMap[value] : null;
        });
      },
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please select your grade';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordInput() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: (val) {
        if (val == null || val.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
      style: AppTypography.bodyXl,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputFill,
        hintText: '••••••••',
        hintStyle: AppTypography.bodyXl.copyWith(
          color: AppColors.inputPlaceholder,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(AppIcons.lock, color: AppColors.authIconBrown, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
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
          borderRadius: AppRadius.roundedLg,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: const BorderSide(color: AppColors.mainAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedLg,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildSignUpButton({bool isLoading = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : _handleSignUp,
        borderRadius: BorderRadius.circular(9999),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: isLoading
                ? AppColors.orange500.withValues(alpha: 0.7)
                : AppColors.orange500,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: AppElevation.elevation1,
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign Up',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.surfaceWhite,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        AppIcons.arrowForward,
                        size: 16,
                        color: AppColors.surfaceWhite,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignUpButton() {
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
              Text('Sign up with Google', style: AppTypography.labelMd),
            ],
          ),
        ),
      ),
    );
  }
}
