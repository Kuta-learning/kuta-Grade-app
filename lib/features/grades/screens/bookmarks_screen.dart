import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../widgets/grade_screen_shell.dart';

/// Screen displaying bookmarked subjects, past exam papers, and questions.
/// Uses [CacheManager] with 1-minute SWR caching to render cached items immediately
/// and silently revalidate in the background without requiring manual pull-to-refresh.
class BookmarksScreen extends StatefulWidget {
  final BookmarkService? service;

  const BookmarksScreen({super.key, this.service});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late final BookmarkService _service;
  StreamSubscription? _subscription;
  List<BookmarkItem> _bookmarks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? BookmarkService();
    _listenToBookmarks();
  }

  void _listenToBookmarks() {
    _subscription?.cancel();
    _subscription = _service
        .streamBookmarks(maxStale: const Duration(minutes: 1))
        .listen(
      (response) {
        if (!mounted) return;
        setState(() {
          _bookmarks = response.data;
          _isLoading = false;
          _errorMessage = null;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage =
              error.toString().replaceFirst('Exception: ', '');
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _removeBookmark(BookmarkItem item, int index) async {
    // Optimistic removal
    final removedItem = item;
    setState(() {
      _bookmarks.removeAt(index);
    });

    try {
      await _service.deleteBookmark(item.id);
      if (mounted) {
        AppSnackBar.showSuccess(context, 'Bookmark removed');
      }
    } catch (e) {
      // Rollback on failure
      if (mounted) {
        setState(() {
          _bookmarks.insert(index, removedItem);
        });
        AppSnackBar.showError(
          context,
          'Failed to remove bookmark: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }
  }

  void _navigateToItem(BookmarkItem item) {
    final type = item.type.toUpperCase();

    if (type.contains('NOTE') || type.contains('CHAPTER')) {
      context.push(
        '${RouteNames.lessonDetail}'
        '?chapterId=${Uri.encodeComponent(item.itemId)}'
        '&subject=${Uri.encodeComponent(item.title)}',
      );
      return;
    }

    if (type.contains('LESSON') || type.contains('COURSE')) {
      context.push(
        '${RouteNames.courseDetail}'
        '?courseId=${Uri.encodeComponent(item.itemId)}'
        '&title=${Uri.encodeComponent(item.title)}',
      );
      return;
    }

    // Default: National Exam Attempt or Quiz
    context.push(
      '${RouteNames.nationalExamAttempt}'
      '?examId=${Uri.encodeComponent(item.itemId)}'
      '&title=${Uri.encodeComponent(item.title)}',
    );
  }

  String _resolveSubjectBadge(BookmarkItem item) {
    if (item.metadata != null && item.metadata!['subject'] != null) {
      return item.metadata!['subject'].toString();
    }
    final title = item.title;
    if (title.contains(' - ')) {
      return title.split(' - ').first.trim();
    }
    switch (item.type.toUpperCase()) {
      case 'EXAM_QUESTION':
        return 'National Exam';
      case 'NOTE_CHAPTER':
        return 'Short Notes';
      case 'COURSE_LESSON':
        return 'Course Lesson';
      case 'QUIZ_QUESTION':
        return 'Quiz';
      default:
        return 'Saved Item';
    }
  }

  String _resolveActionLabel(BookmarkItem item) {
    final type = item.type.toUpperCase();
    if (type.contains('NOTE') || type.contains('CHAPTER')) {
      return 'Read Note';
    }
    if (type.contains('LESSON') || type.contains('COURSE')) {
      return 'Study Lesson';
    }
    return 'Start Exam';
  }

  String _formatMeta(BookmarkItem item) {
    final meta = item.metadata;
    final parts = <String>[];

    if (meta != null) {
      if (meta['examYear'] != null) {
        parts.add('${meta['examYear']}');
      }
      if (meta['gradeLevel'] != null) {
        parts.add('Grade ${meta['gradeLevel']}');
      }
      if (meta['stream'] != null) {
        parts.add('${meta['stream']}');
      }
    }

    if (parts.isEmpty && item.createdAt != null) {
      final dt = item.createdAt!;
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      parts.add('Saved on ${months[dt.month - 1]} ${dt.day}');
    }

    return parts.isEmpty ? 'Official Exam Question' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return GradeScreenShell(
      title: 'Bookmarks',
      streamTitle: 'NATURAL SCIENCE STREAM',
      subtitle: 'Saved Exam Papers & Important Questions',
      showBottomNav: false,
      selectedNavIndex: 0,
      actions: const [],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _bookmarks.isEmpty) {
      return const Center(
        child: KutaLoadingWidget(
          size: 130,
          label: 'Loading Bookmarks...',
        ),
      );
    }

    if (_errorMessage != null && _bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load bookmarks',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _listenToBookmarks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bookmark_border_rounded,
                  size: 40,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No bookmarks yet',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap the bookmark icon on any exam paper or note to save it here for fast revision.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 108),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        final item = _bookmarks[index];
        final badge = _resolveSubjectBadge(item);
        final meta = _formatMeta(item);
        final actionLabel = _resolveActionLabel(item);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.containerHigh, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Subject/Type Badge & Bookmark Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.bookmark_rounded,
                        color: AppColors.orange500,
                        size: 22,
                      ),
                      tooltip: 'Remove bookmark',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _removeBookmark(item, index),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Bottom Row: Metadata & Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13.5,
                            color: AppColors.brandBlue,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              meta,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => _navigateToItem(item),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orange500,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          actionLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
