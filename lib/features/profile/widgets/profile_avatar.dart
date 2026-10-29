import 'package:flutter/material.dart';

import '../models/profile_model.dart';
/// Circular avatar with the orange brand ring, soft peach glow, and a
/// bottom-right pencil edit badge — matching the Figma profile header.
/// The edit badge is visual-only this phase (avatar editing comes later).
class ProfileAvatar extends StatelessWidget {
  final ProfileModel? profile;
  final double size;
  final VoidCallback? onEditTapped;

  const ProfileAvatar({
    super.key,
    this.profile,
    this.size = 96,
    this.onEditTapped,
  });

  String get _initials {
    final name = profile?.fullName ?? '';
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    final buffer = StringBuffer(parts.first[0].toUpperCase());
    if (parts.length > 1) {
      buffer.write(parts.last[0].toUpperCase());
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    const badgeSize = 30.0;
    const ringWidth = 3.5;
    final effectiveImageUrl = (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty)
        ? profile!.avatarUrl!
        : 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=300&auto=format&fit=crop';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ring + soft peach glow + avatar image
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF6A00),
                width: ringWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6A00).withValues(alpha: 0.22),
                  spreadRadius: 3,
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                effectiveImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallback(badgeSize),
              ),
            ),
          ),
          // Pencil edit badge (bottom-right)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEditTapped,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF5A2508), // Dark chocolate/bronze from screenshot
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(double iconSize) {
    final initials = _initials;
    if (initials.isEmpty) {
      return Container(
        color: const Color(0xFFE2E8F0),
        child: const Icon(
          Icons.person,
          size: 48,
          color: Color(0xFF0F4C97),
        ),
      );
    }
    return Container(
      color: const Color(0xFFE2E8F0),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F4C97),
        ),
      ),
    );
  }
}
