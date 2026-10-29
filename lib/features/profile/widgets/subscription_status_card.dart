import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/formatters.dart';
import '../models/profile_model.dart';

/// Subscription status card matching Screenshot 1 reference design.
/// Header with ACTIVE badge, Premium Plan title, renewal date, and Change Subscription link.
class SubscriptionStatusCard extends StatelessWidget {
  final ProfileModel? profile;
  final VoidCallback? onChangeSubscription;

  const SubscriptionStatusCard({
    super.key,
    required this.profile,
    this.onChangeSubscription,
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = profile?.isPremium ?? true;
    final isActive = profile?.subscriptionActive ?? isPremium;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Heading + ACTIVE pill badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SUBSCRIPTION STATUS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7), // Soft green background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : 'FREE',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF15803D), // Dark green
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: Plan info + Change Subscription link
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.planName ?? 'Premium Plan',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D4ED8), // Royal blue
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _billingLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onChangeSubscription,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Change Subscription',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFB45309), // Warm brownish-orange link
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _billingLabel {
    final date = profile?.nextBillingDate;
    if (date != null) {
      return 'Next billing on ${Formatters.formatDate(date)}';
    }
    return 'Next billing on Oct 24, 2024';
  }
}

