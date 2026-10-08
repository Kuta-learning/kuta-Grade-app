import 'package:flutter/material.dart';
import '../models/subject_model.dart';

/// Reusable subject card component shared across Grades 6, 8, and 12.
class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final VoidCallback? onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subject.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('${subject.completedChapters} / ${subject.totalChapters} Chapters'),
            ],
          ),
        ),
      ),
    );
  }
}
