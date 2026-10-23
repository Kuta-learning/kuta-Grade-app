import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../services/auth_service.dart';

/// Premium 6-digit OTP verification screen matching the Kuta design language.
/// Features dedicated pin boxes, auto-advance, backspace handling, clipboard pasting,
/// 60s countdown resend timer, and connection with the password reset flow.
class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;

  // Countdown timer
  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    // Check if pasted multiple digits
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        for (int i = 0; i < _otpLength; i++) {
          if (i < digits.length) {
            _controllers[i].text = digits[i];
          }
        }
        final targetIndex =
            (digits.length >= _otpLength) ? _otpLength - 1 : digits.length;
        _focusNodes[targetIndex].requestFocus();
        if (digits.length >= _otpLength) {
          _handleVerify();
        }
        setState(() {});
        return;
      }
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_currentOtp.length == _otpLength) {
          _handleVerify();
        }
      }
    }
    setState(() {});
  }

  Future<void> _handleVerify() async {
    final otp = _currentOtp.trim();
    if (otp.length < _otpLength) {
      AppSnackBar.showError(
        context,
        'Please enter all 6 digits of your verification code.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authBloc = context.read<AuthBloc>();
      final resetToken = await authBloc.authService.verifyOtp(
        email: widget.email,
        otp: otp,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      AppSnackBar.showSuccess(
        context,
        'Code verified successfully! Set your new password.',
        title: 'Verified',
      );

      // Navigate to Reset Password Screen with email and resetToken
      context.push(
        '${RouteNames.resetPassword}?email=${Uri.encodeComponent(widget.email)}&token=${Uri.encodeComponent(resetToken)}',
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
        'Verification failed. Please check the code and try again.',
      );
    }
  }

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      final authBloc = context.read<AuthBloc>();
      await authBloc.authService.requestPasswordReset(widget.email);

      if (!mounted) return;
      setState(() => _isResending = false);

      // Clear input fields
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();

      _startCountdown();

      AppSnackBar.showSuccess(
        context,
        'A fresh 6-digit code has been sent to ${widget.email}.',
        title: 'Code Resent',
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
      AppSnackBar.showError(context, e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isResending = false);
      AppSnackBar.showError(context, 'Could not resend code. Please try again.');
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
    final formattedTime =
        '00:${_secondsRemaining.toString().padLeft(2, '0')}';

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
                constraints: const BoxConstraints(maxWidth: 380),
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
                        color: const Color(0xFFFDEEE3), // Soft terracotta tint
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mark_email_read_outlined,
                          size: 40,
                          color: Color(0xFF9D4300), // Deep terracotta
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==========================================
                    // 2. TITLE & SUBTITLE
                    // ==========================================
                    Text(
                      'Enter Verification Code',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineLg.copyWith(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: AppColors.headlineDark,
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text.rich(
                        TextSpan(
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.authBrown,
                            fontSize: 14.5,
                            height: 1.45,
                          ),
                          children: [
                            const TextSpan(
                              text: "We've sent a 6-digit verification code to\n",
                            ),
                            TextSpan(
                              text: widget.email.isNotEmpty
                                  ? widget.email
                                  : 'your email address',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const TextSpan(
                              text: '. Enter it below to continue.',
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==========================================
                    // 3. WHITE FORM CARD WITH OTP BOXES
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
                        horizontal: 16.0,
                        vertical: 28.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Label: Verification Code
                          Center(
                            child: Text(
                              '6-DIGIT CODE',
                              style: AppTypography.captionSm.copyWith(
                                color:
                                    AppColors.authBrown.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                fontSize: 11.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 6 Digit Input Boxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(_otpLength, (index) {
                              return _buildOtpDigitBox(index);
                            }),
                          ),

                          const SizedBox(height: 24),

                          // Resend Code Section
                          Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _secondsRemaining > 0
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.access_time_rounded,
                                          size: 15,
                                          color: AppColors.authBrown,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "Didn't get code? Resend in $formattedTime",
                                          style: AppTypography.captionSm.copyWith(
                                            color: AppColors.authBrown,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Didn't receive code? ",
                                          style: AppTypography.captionSm.copyWith(
                                            color: AppColors.authBrown,
                                            fontSize: 13,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _isResending
                                              ? null
                                              : _handleResend,
                                          child: _isResending
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Color(0xFF2563EB),
                                                  ),
                                                )
                                              : Text(
                                                  'Resend Code',
                                                  style: AppTypography
                                                      .labelMdSemiBold
                                                      .copyWith(
                                                    color:
                                                        const Color(0xFF2563EB),
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // CTA: Verify Button
                          _buildVerifyButton(),
                        ],
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

  Widget _buildOtpDigitBox(int index) {
    final controller = _controllers[index];
    final focusNode = _focusNodes[index];
    final isFilled = controller.text.isNotEmpty;

    return SizedBox(
      width: 44,
      height: 54,
      child: KeyboardListener(
        focusNode: FocusNode(), // auxiliary node for key interception
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (controller.text.isEmpty && index > 0) {
              _controllers[index - 1].clear();
              _focusNodes[index - 1].requestFocus();
              setState(() {});
            }
          }
        },
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: AppTypography.headlineMd.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.headlineDark,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: isFilled
                ? const Color(0xFFFDEEE3).withValues(alpha: 0.35)
                : AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.borderVariant,
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isFilled ? AppColors.orange500 : AppColors.borderVariant,
                width: isFilled ? 1.5 : 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.orange500,
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (val) => _onDigitChanged(index, val),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    final isComplete = _currentOtp.length == _otpLength;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (_isLoading || !isComplete) ? null : _handleVerify,
        borderRadius: BorderRadius.circular(9999),
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            color: (_isLoading || !isComplete)
                ? AppColors.orange500.withValues(alpha: 0.5)
                : AppColors.orange500,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: isComplete
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(249, 115, 22, 0.25),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ]
                : null,
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
                        'Verify Code',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.surfaceWhite,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle_outline,
                        size: 19,
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
