import 'package:flutter/material.dart';
import '../models/chapter_model.dart';

/// Reusable chapter list row item shared across grades.
class ChapterListTile extends StatelessWidget {
  final ChapterModel chapter;
  final VoidCallback? onTap;

  const ChapterListTile({
    super.key,
    required this.chapter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text('${chapter.chapterNumber}'),
      ),
      title: Text(chapter.title),
      trailing: Icon(
        chapter.isCompleted ? Icons.check_circle : Icons.chevron_right,
        color: chapter.isCompleted ? Colors.green : null,
      ),
      onTap: onTap,
    );
  }
}
