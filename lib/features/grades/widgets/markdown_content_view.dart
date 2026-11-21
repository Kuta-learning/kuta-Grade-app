import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../models/note_models.dart';

/// Renders markdown formatted content, properly parsing embedded markdown
/// images (![alt](url)), headings, bullet points, and inline formatting.
class MarkdownContentView extends StatelessWidget {
  final String content;

  const MarkdownContentView({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final blocks = _parseBlocks(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _buildBlock(context, blocks[i]),
        ],
      ],
    );
  }

  List<_ContentBlock> _parseBlocks(String raw) {
    final blocks = <_ContentBlock>[];
    // Normalize line endings
    final text = raw.replaceAll('\r\n', '\n');

    final imgRegex = RegExp(r'!\[([^\]]*)\]\(([^)]+)\)');
    int lastIndex = 0;

    for (final match in imgRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        final textChunk = text.substring(lastIndex, match.start);
        if (textChunk.trim().isNotEmpty) {
          blocks.add(_ContentBlock(
            type: _BlockType.text,
            text: textChunk.trim(),
          ));
        }
      }

      final alt = match.group(1)?.trim() ?? '';
      final rawUrl = match.group(2)?.trim() ?? '';
      if (rawUrl.isNotEmpty) {
        blocks.add(_ContentBlock(
          type: _BlockType.image,
          text: alt,
          imageUrl: rawUrl,
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      final remaining = text.substring(lastIndex);
      if (remaining.trim().isNotEmpty) {
        blocks.add(_ContentBlock(
          type: _BlockType.text,
          text: remaining.trim(),
        ));
      }
    }

    return blocks;
  }

  Widget _buildBlock(BuildContext context, _ContentBlock block) {
    if (block.type == _BlockType.image) {
      return _buildImageBlock(block.imageUrl ?? '', block.text);
    }
    return _buildTextBlock(block.text);
  }

  Widget _buildImageBlock(String rawUrl, String altText) {
    final resolvedUrl = resolveBackendUrl(rawUrl);
    final isNetwork =
        resolvedUrl.startsWith('http://') || resolvedUrl.startsWith('https://');

    // Only display alt as caption if it looks like a human-readable title,
    // not a hex/hash ID or filename.
    final showCaption = _isReadableCaption(altText);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isNetwork
                ? Image.network(
                    resolvedUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      final total = loadingProgress.expectedTotalBytes;
                      final loaded = loadingProgress.cumulativeBytesLoaded;
                      final progress =
                          total != null && total > 0 ? loaded / total : null;
                      return Container(
                        height: 180,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 2.5,
                            color: AppColors.orange500,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textSecondary,
                            size: 32,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Image unavailable',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamilyOpenSans,
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Image.asset(
                    resolvedUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
          ),
          if (showCaption) ...[
            const SizedBox(height: 8),
            Text(
              altText,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamilyOpenSans,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  bool _isReadableCaption(String s) {
    if (s.isEmpty) return false;
    // Discard hash strings like "173922030863c5c66b05da45f8c61a7f727aeb1961aa8e209b"
    if (RegExp(r'^[a-f0-9_-]{12,}$', caseSensitive: false).hasMatch(s)) {
      return false;
    }
    if (RegExp(r'^\d{10,}').hasMatch(s)) {
      return false;
    }
    if (s.contains('.jpg') || s.contains('.png') || s.contains('.jpeg')) {
      return false;
    }
    return true;
  }

  Widget _buildTextBlock(String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // Headings
      if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.substring(4).trim(),
              style: const TextStyle(
                fontFamily: AppTypography.fontFamilyPoppins,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.headlineDark,
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Text(
              line.substring(3).trim(),
              style: const TextStyle(
                fontFamily: AppTypography.fontFamilyPoppins,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: AppColors.headlineDark,
              ),
            ),
          ),
        );
      } else if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              line.substring(2).trim(),
              style: const TextStyle(
                fontFamily: AppTypography.fontFamilyPoppins,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.headlineDark,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        // Bullet list item
        final bulletText = line.substring(2).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6, right: 8),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: AppColors.orange500,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: _parseInlineSpans(
                        bulletText,
                        const TextStyle(
                          fontFamily: AppTypography.fontFamilyOpenSans,
                          fontSize: 13.5,
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Standard paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: RichText(
              text: TextSpan(
                children: _parseInlineSpans(
                  line,
                  const TextStyle(
                    fontFamily: AppTypography.fontFamilyOpenSans,
                    fontSize: 13.5,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<InlineSpan> _parseInlineSpans(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final boldRegex = RegExp(r'\*\*(.+?)\*\*');
    int lastIndex = 0;

    for (final match in boldRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }
      final boldContent = match.group(1) ?? '';
      spans.add(TextSpan(
        text: boldContent,
        style: baseStyle.copyWith(fontWeight: FontWeight.w700),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return spans;
  }
}

enum _BlockType { text, image }

class _ContentBlock {
  final _BlockType type;
  final String text;
  final String? imageUrl;

  _ContentBlock({
    required this.type,
    required this.text,
    this.imageUrl,
  });
}

