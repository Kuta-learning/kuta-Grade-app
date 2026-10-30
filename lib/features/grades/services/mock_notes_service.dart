import 'package:flutter/material.dart';
import '../models/note_models.dart';
import 'notes_service.dart';

/// Offline mock implementation providing pixel-accurate data for screens and unit tests.
class MockNotesService implements NotesService {
  @override
  Future<List<NoteSubjectItem>> getShortNotesSubjects() async {
    // Slight simulation delay
    await Future.delayed(const Duration(milliseconds: 150));
    return const [
      // Mathematics — peach icon with Σ symbol (matches screenshot)
      NoteSubjectItem(
        id: 'math',
        name: 'Mathematics',
        iconBgColor: Color(0xFFFFDBCA),
        iconColor: Color(0xFF341100),
        isSymbol: true,
        symbol: 'Σ',
        grades: [
          NoteGradeOption(name: 'Grade 9', chapters: '8 Chapters', gradeLevel: 9),
          NoteGradeOption(name: 'Grade 10', chapters: '10 Chapters', gradeLevel: 10),
          NoteGradeOption(name: 'Grade 11', chapters: '12 Chapters', gradeLevel: 11),
          NoteGradeOption(name: 'Grade 12', chapters: '14 Chapters', gradeLevel: 12),
        ],
      ),
      // Physics — blue icon (matches screenshot)
      NoteSubjectItem(
        id: 'physics',
        name: 'Physics',
        iconBgColor: Color(0xFFDBE9FF),
        iconColor: Color(0xFF1A56DB),
        iconDataName: 'offline_bolt_outlined',
        grades: [
          NoteGradeOption(name: 'Grade 9', chapters: '7 Chapters', gradeLevel: 9),
          NoteGradeOption(name: 'Grade 10', chapters: '8 Chapters', gradeLevel: 10),
          NoteGradeOption(name: 'Grade 11', chapters: '10 Chapters', gradeLevel: 11),
          NoteGradeOption(name: 'Grade 12', chapters: '12 Chapters', gradeLevel: 12),
        ],
      ),
      // Chemistry — green icon (matches screenshot)
      NoteSubjectItem(
        id: 'chemistry',
        name: 'Chemistry',
        iconBgColor: Color(0xFFD1FAE5),
        iconColor: Color(0xFF065F46),
        iconDataName: 'science_outlined',
        grades: [
          NoteGradeOption(name: 'Grade 9', chapters: '6 Chapters', gradeLevel: 9),
          NoteGradeOption(name: 'Grade 10', chapters: '8 Chapters', gradeLevel: 10),
          NoteGradeOption(name: 'Grade 11', chapters: '10 Chapters', gradeLevel: 11),
          NoteGradeOption(name: 'Grade 12', chapters: '12 Chapters', gradeLevel: 12),
        ],
      ),
      // Biology — warm orange/amber icon (matches screenshot)
      NoteSubjectItem(
        id: 'biology',
        name: 'Biology',
        iconBgColor: Color(0xFFFFEDD5),
        iconColor: Color(0xFF9A3412),
        iconDataName: 'psychology_outlined',
        grades: [
          NoteGradeOption(name: 'Grade 9', chapters: '6 Chapters', gradeLevel: 9),
          NoteGradeOption(name: 'Grade 10', chapters: '7 Chapters', gradeLevel: 10),
          NoteGradeOption(name: 'Grade 11', chapters: '9 Chapters', gradeLevel: 11),
          NoteGradeOption(name: 'Grade 12', chapters: '11 Chapters', gradeLevel: 12),
        ],
      ),
      // English — blue icon (matches screenshot)
      NoteSubjectItem(
        id: 'english',
        name: 'English',
        iconBgColor: Color(0xFFDBE9FF),
        iconColor: Color(0xFF1A56DB),
        iconDataName: 'menu_book_rounded',
        grades: [
          NoteGradeOption(name: 'Grade 9', chapters: '8 Chapters', gradeLevel: 9),
          NoteGradeOption(name: 'Grade 10', chapters: '9 Chapters', gradeLevel: 10),
          NoteGradeOption(name: 'Grade 11', chapters: '10 Chapters', gradeLevel: 11),
          NoteGradeOption(name: 'Grade 12', chapters: '12 Chapters', gradeLevel: 12),
        ],
      ),
      // Civics & Ethics — warm brown icon (matches screenshot)
      NoteSubjectItem(
        id: 'civics',
        name: 'Civics & Ethics',
        iconBgColor: Color(0xFFE8DCCA),
        iconColor: Color(0xFF584237),
        iconDataName: 'balance_rounded',
        grades: [
          NoteGradeOption(name: 'Grade 9', chapters: '5 Chapters', gradeLevel: 9),
          NoteGradeOption(name: 'Grade 10', chapters: '6 Chapters', gradeLevel: 10),
          NoteGradeOption(name: 'Grade 11', chapters: '8 Chapters', gradeLevel: 11),
          NoteGradeOption(name: 'Grade 12', chapters: '10 Chapters', gradeLevel: 12),
        ],
      ),
    ];
  }

  @override
  Future<SubjectNotesDetail> getSubjectNotesDetails(String subjectId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const SubjectNotesDetail(
      subjectId: 'math-12',
      subjectTitle: 'Mathematics',
      gradeLevel: 'Grade 12',
      totalChapters: 14,
      totalFileSize: '42 MB',
      downloadAllUrl: 'https://kuta-learning.onrender.com/api/short-notes/math-12/download-all',
      chapters: [
        ChapterNoteItem(
          id: 'chap-1',
          chapterNumber: '1',
          title: '1. Limits and Continuity',
          description:
              'Understanding limits at infinity, one-sided limits, continuity theorems, and standard indeterminate forms.',
          pageCount: '12 Pages',
          fileSize: '2.4 MB',
          isCompleted: true,
        ),
        ChapterNoteItem(
          id: 'chap-2',
          chapterNumber: '2',
          title: '2. Derivatives and Differentiation Techniques',
          description:
              'Product rule, quotient rule, chain rule, implicit differentiation, and higher-order derivatives with practical examples.',
          pageCount: '18 Pages',
          fileSize: '3.1 MB',
          isCompleted: true,
        ),
        ChapterNoteItem(
          id: 'chap-3',
          chapterNumber: '3',
          title: '3. Applications of Differential Calculus',
          description:
              'Optimization problems, rate of change, curve sketching, tangent & normal equations, and Rolle\u2019s theorem.',
          pageCount: '15 Pages',
          fileSize: '2.8 MB',
          isCompleted: false,
        ),
        ChapterNoteItem(
          id: 'chap-4',
          chapterNumber: '4',
          title: '4. Integrals and Antiderivatives',
          description:
              'Indefinite and definite integrals, integration by substitution, integration by parts, and fundamental theorem of calculus.',
          pageCount: '22 Pages',
          fileSize: '4.2 MB',
          isCompleted: false,
        ),
        ChapterNoteItem(
          id: 'chap-5',
          chapterNumber: '5',
          title: '5. Applications of Definite Integrals',
          description:
              'Area between curves, volume of solids of revolution (disk and washer methods), and arc length calculations.',
          pageCount: '14 Pages',
          fileSize: '2.9 MB',
          isCompleted: false,
        ),
      ],
    );
  }

  @override
  Future<LessonDetail> getChapterNoteDetail(String chapterId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const LessonDetail(
      chapterId: 'chap-4-2',
      chapterTitle: 'Equivalence and Simplification',
      chapterNumber: '4.2',
      subject: 'Fractions',
      gradeLevel: 'Grade 8 Math',
      learningObjectives: [
        'Define equivalent fractions and recognize them visually using area models.',
        'Apply the fundamental property of fractions to create equivalent fractions by multiplication.',
        'Master the technique of simplifying fractions to their lowest terms using the GCF (Greatest Common Factor).',
      ],
      sectionHeading: 'What are Equivalent Fractions?',
      bodyText:
          'Equivalent fractions are fractions that represent the same value, even though they look different. For example, 1/2 and 2/4 are equivalent. You can find equivalent fractions by multiplying or dividing both the numerator and the denominator by the same non-zero number.',
      diagrams: [
        LessonDiagram(
          title: 'Simplifying 8/12 using GCF',
          imageAssetOrUrl: 'assets/images/fraction_simplify_card.png',
          caption: 'Simplifying 8/12 using GCF',
          label: 'Diagram 1',
          subtitle: 'Simplifying 8/12 using GCF',
        ),
      ],
      steps: [
        LessonStep(
          number: 1,
          title: '',
          text:
              'Find the **Greatest Common Factor (GCF)** of the numerator and the denominator.',
          highlightText: 'Greatest Common Factor (GCF)',
        ),
        LessonStep(
          number: 2,
          title: '',
          text:
              'Divide both the numerator and the denominator by the GCF.',
        ),
        LessonStep(
          number: 3,
          title: '',
          text:
              'Rewrite the fraction with the new values. It is now in its **simplest form**!',
          highlightText: 'simplest form',
        ),
      ],
      resources: [
        LessonResource(
          id: 'res-1',
          title: 'Equation_Worksheet.pdf',
          fileSize: '2.4 MB',
          fileType: 'Printable',
          downloadUrl:
              'https://kuta-learning.onrender.com/api/resources/equation-worksheet.pdf',
        ),
        LessonResource(
          id: 'res-2',
          title: 'Instructor_Notes.docx',
          fileSize: '1.1 MB',
          fileType: 'Summary',
          downloadUrl:
              'https://kuta-learning.onrender.com/api/resources/instructor-notes.docx',
        ),
      ],
      progressPercent: 1.0,
    );
  }

  @override
  Future<void> updateChapterReadingProgress(
    String chapterId, {
    required bool isRead,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<String> downloadChapterPdf(String chapterId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return 'https://kuta-learning.onrender.com/api/short-notes/$chapterId/download';
  }
}
