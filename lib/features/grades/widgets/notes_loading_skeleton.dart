import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Loading skeleton placeholder for Notes subject and chapter lists.
class NotesLoadingSkeleton extends StatelessWidget {
  final int itemCount;

  const NotesLoadingSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 180,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

