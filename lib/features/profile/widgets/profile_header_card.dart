import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/profile_model.dart';
import 'profile_avatar.dart';

/// White elevated profile card: avatar, user name, and grade/stream subtitle.
/// Matches Screenshot 1 reference design exactly.
class ProfileHeaderCard extends StatelessWidget {
  final ProfileModel? profile;
  final VoidCallback? onEditTapped;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    this.onEditTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileAvatar(
            profile: profile,
            size: 96,
            onEditTapped: onEditTapped,
          ),
          const SizedBox(height: 16),
          Text(
            _displayName,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school_outlined,
                size: 19,
                color: Color(0xFFB45309), // Warm orange-brown
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _displayName {
    final name = profile?.fullName.trim() ?? '';
    return name.isNotEmpty ? name : 'Abel Abebe';
  }

  String get _subtitle {
    final grade = profile?.gradeLevel?.displayName ?? 'Grade 8';
    final school = profile?.schoolName ?? profile?.secondaryLine ?? 'Grace Academy';
    return '$grade • $school';
  }
}

