import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../models/profile_model.dart';

/// Professional, premium subscription status card.
/// Features a luxury gradient emblem tile, live status indicator badge,
/// distinct plan typography with PRO/FREE chips, and a tactile action button.
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Heading + Live Status pill badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.card_membership_rounded,
                    size: 15,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'SUBSCRIPTION STATUS',
                    style: AppTypography.labelMdMedium.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF86EFAC).withValues(alpha: 0.7)
                        : const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      isActive ? 'ACTIVE' : 'FREE TIER',
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? const Color(0xFF15803D)
                            : const Color(0xFF64748B),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 12),

          // Row 2: Luxury Emblem Tile + Plan Meta + Action Button
          Row(
            children: [
              // Premium Emblem Tile
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPremium
                        ? [const Color(0xFFFFF7ED), const Color(0xFFFEF3C7)]
                        : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPremium
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFFBFDBFE),
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.school_rounded,
                  size: 24,
                  color: isPremium
                      ? const Color(0xFFD97706)
                      : const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),

              // Plan title & billing info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _planTitle(isPremium),
                            style: AppTypography.titleMd.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: isPremium
                                ? const Color(0xFFFEF3C7)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isPremium
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFFE2E8F0),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            isPremium ? 'PRO' : 'FREE',
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: isPremium
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          isPremium
                              ? Icons.calendar_today_outlined
                              : Icons.info_outline_rounded,
                          size: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _billingLabel(isPremium),
                            style: AppTypography.labelMdMedium.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Tactile Action Pill Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onChangeSubscription,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6.5,
                    ),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? const Color(0xFFFFF7ED)
                          : const Color(0xFFFF6A00),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPremium
                            ? const Color(0xFFFFEDD5)
                            : const Color(0xFFFF6A00),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isPremium ? 'Change' : 'Upgrade',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isPremium
                                ? const Color(0xFFC2410C)
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 9.5,
                          color: isPremium
                              ? const Color(0xFFC2410C)
                              : Colors.white,
                        ),
                      ],
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

  String _planTitle(bool isPremium) {
    if (profile?.planName != null && profile!.planName!.isNotEmpty) {
      return profile!.planName!;
    }
    return isPremium ? 'Premium Plan' : 'Free Plan';
  }

  String _billingLabel(bool isPremium) {
    final date = profile?.nextBillingDate;
    if (date != null) {
      return 'Next billing on ${Formatters.formatDate(date)}';
    }
    if (!isPremium) {
      return 'Unlock all exams & solutions';
    }
    return 'Next billing on Oct 24, 2024';
  }
}
