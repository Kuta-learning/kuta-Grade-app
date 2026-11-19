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
    final norm = subjectId.toLowerCase();

    if (norm.contains('civic') ||
        norm.contains('ethic') ||
        norm == 'd389bc5e-8f77-45c4-8a3b-36b22a817cf8') {
      return const SubjectNotesDetail(
        subjectId: 'd389bc5e-8f77-45c4-8a3b-36b22a817cf8',
        subjectTitle: 'Civics & Ethical Education',
        gradeLevel: 'Grade 10',
        totalChapters: 6,
        totalFileSize: '28 MB',
        downloadAllUrl:
            'https://kuta-learning.onrender.com/api/short-notes/civics/download-all',
        chapters: [
          ChapterNoteItem(
            id: 'chap-civ-1',
            chapterNumber: '1',
            title: '1. Building a Democratic System',
            description:
                'Fundamental democratic principles, constitutionalism, separation of powers, and civic participation.',
            pageCount: '14 Pages',
            fileSize: '3.2 MB',
            isCompleted: true,
          ),
          ChapterNoteItem(
            id: 'chap-civ-2',
            chapterNumber: '2',
            title: '2. The Rule of Law and Constitutional Supremacy',
            description:
                'Due process of law, judicial independence, constitutional safeguards, and combating institutional abuses.',
            pageCount: '16 Pages',
            fileSize: '3.8 MB',
            isCompleted: true,
          ),
          ChapterNoteItem(
            id: 'chap-civ-3',
            chapterNumber: '3',
            title: '3. Equality and Human Rights in Modern Society',
            description:
                'Universal human rights, protection of minority rights, gender equity, and eradicating discrimination.',
            pageCount: '12 Pages',
            fileSize: '2.6 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-civ-4',
            chapterNumber: '4',
            title: '4. Justice, Fairness and Institutional Integrity',
            description:
                'Distributive and procedural justice, combating corruption, fair taxation, and social equity programs.',
            pageCount: '15 Pages',
            fileSize: '3.4 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-civ-5',
            chapterNumber: '5',
            title: '5. Patriotic Citizenship and Civic Duty',
            description:
                'National public interest, environmental stewardship, active volunteerism, and civic responsibility.',
            pageCount: '18 Pages',
            fileSize: '4.1 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-civ-6',
            chapterNumber: '6',
            title: '6. Professional Ethics and Public Accountability',
            description:
                'Professional standards, integrity in government service, code of conduct, and whistleblowing safeguards.',
            pageCount: '13 Pages',
            fileSize: '2.9 MB',
            isCompleted: false,
          ),
        ],
      );
    }

    if (norm.contains('physic') ||
        norm == '9553848a-768c-46ac-934c-4a11dc4474f8') {
      return const SubjectNotesDetail(
        subjectId: '9553848a-768c-46ac-934c-4a11dc4474f8',
        subjectTitle: 'Physics',
        gradeLevel: 'Grade 12',
        totalChapters: 5,
        totalFileSize: '36 MB',
        downloadAllUrl:
            'https://kuta-learning.onrender.com/api/short-notes/physics/download-all',
        chapters: [
          ChapterNoteItem(
            id: 'chap-phys-1',
            chapterNumber: '1',
            title: '1. Thermodynamics and Gas Laws',
            description:
                'First and second laws of thermodynamics, heat engines, Carnot cycle, and kinetic theory of gases.',
            pageCount: '16 Pages',
            fileSize: '3.8 MB',
            isCompleted: true,
          ),
          ChapterNoteItem(
            id: 'chap-phys-2',
            chapterNumber: '2',
            title: '2. Oscillations, Waves and Optics',
            description:
                'Simple harmonic motion, sound waves, interference, diffraction, and thin-film wave mechanics.',
            pageCount: '19 Pages',
            fileSize: '4.4 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-phys-3',
            chapterNumber: '3',
            title: '3. Electrostatics and Electric Potential',
            description:
                'Coulomb’s law, electric field lines, Gauss’s law, capacitors, and dielectrics.',
            pageCount: '21 Pages',
            fileSize: '5.1 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-phys-4',
            chapterNumber: '4',
            title: '4. Electromagnetism and AC Circuits',
            description:
                'Magnetic force on moving charges, Ampere’s law, Faraday’s law of induction, and alternating currents.',
            pageCount: '22 Pages',
            fileSize: '5.3 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-phys-5',
            chapterNumber: '5',
            title: '5. Atomic and Nuclear Physics',
            description:
                'Photoelectric effect, Compton scattering, Bohr model, radioactivity, and nuclear binding energy.',
            pageCount: '15 Pages',
            fileSize: '3.5 MB',
            isCompleted: false,
          ),
        ],
      );
    }

    if (norm.contains('chem') ||
        norm == '078bd042-8dcc-46f0-825a-f94bcd63fbd1') {
      return const SubjectNotesDetail(
        subjectId: '078bd042-8dcc-46f0-825a-f94bcd63fbd1',
        subjectTitle: 'Chemistry',
        gradeLevel: 'Grade 12',
        totalChapters: 5,
        totalFileSize: '34 MB',
        downloadAllUrl:
            'https://kuta-learning.onrender.com/api/short-notes/chem/download-all',
        chapters: [
          ChapterNoteItem(
            id: 'chap-chem-1',
            chapterNumber: '1',
            title: '1. Chemical Equilibrium and Le Chatelier',
            description:
                'Dynamic equilibrium, equilibrium constant Kc and Kp, reaction quotient, and temperature shifts.',
            pageCount: '14 Pages',
            fileSize: '3.1 MB',
            isCompleted: true,
          ),
          ChapterNoteItem(
            id: 'chap-chem-2',
            chapterNumber: '2',
            title: '2. Acid-Base Equilibria and Buffer Solutions',
            description:
                'Brønsted-Lowry and Lewis acid-base theories, pH calculations, buffer capacity, and titration curves.',
            pageCount: '18 Pages',
            fileSize: '4.0 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-chem-3',
            chapterNumber: '3',
            title: '3. Electrochemistry and Galvanic Cells',
            description:
                'Standard reduction potentials, Nernst equation, electrolytic cells, and Faraday’s laws of electrolysis.',
            pageCount: '17 Pages',
            fileSize: '3.9 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-chem-4',
            chapterNumber: '4',
            title: '4. Hydrocarbons and Functional Groups',
            description:
                'Alkanes, alkenes, alkynes, aromatic compounds, isomerism, and organic synthesis pathways.',
            pageCount: '23 Pages',
            fileSize: '5.2 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-chem-5',
            chapterNumber: '5',
            title: '5. Polymers and Biomolecules',
            description:
                'Addition and condensation polymerization, carbohydrates, amino acids, and nucleic acids.',
            pageCount: '16 Pages',
            fileSize: '3.6 MB',
            isCompleted: false,
          ),
        ],
      );
    }

    if (norm.contains('bio') ||
        norm == '361d135f-1147-4bdf-b688-1f8ca6f76204') {
      return const SubjectNotesDetail(
        subjectId: '361d135f-1147-4bdf-b688-1f8ca6f76204',
        subjectTitle: 'Biology',
        gradeLevel: 'Grade 12',
        totalChapters: 5,
        totalFileSize: '38 MB',
        downloadAllUrl:
            'https://kuta-learning.onrender.com/api/short-notes/bio/download-all',
        chapters: [
          ChapterNoteItem(
            id: 'chap-bio-1',
            chapterNumber: '1',
            title: '1. Cellular Respiration and Photosynthesis',
            description:
                'Glycolysis, Krebs cycle, electron transport chain, light-dependent reactions, and Calvin cycle.',
            pageCount: '19 Pages',
            fileSize: '4.5 MB',
            isCompleted: true,
          ),
          ChapterNoteItem(
            id: 'chap-bio-2',
            chapterNumber: '2',
            title: '2. Molecular Genetics and DNA Replication',
            description:
                'DNA structure, semi-conservative replication, transcription, translation, and genetic mutations.',
            pageCount: '21 Pages',
            fileSize: '4.8 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-bio-3',
            chapterNumber: '3',
            title: '3. Evolutionary Biology and Population Genetics',
            description:
                'Darwinian natural selection, speciation mechanisms, Hardy-Weinberg equilibrium, and fossil evidence.',
            pageCount: '16 Pages',
            fileSize: '3.7 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-bio-4',
            chapterNumber: '4',
            title: '4. Human Nervous and Endocrine Systems',
            description:
                'Action potentials, synaptic transmission, reflex arcs, pituitary hormones, and feedback mechanisms.',
            pageCount: '20 Pages',
            fileSize: '4.6 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-bio-5',
            chapterNumber: '5',
            title: '5. Ecology, Conservation and Ecosystems',
            description:
                'Biogeochemical cycles, energy trophic pyramids, population dynamics, and biodiversity preservation.',
            pageCount: '18 Pages',
            fileSize: '4.2 MB',
            isCompleted: false,
          ),
        ],
      );
    }

    if (norm.contains('eng') ||
        norm == '067159b7-ed17-4859-99e8-34d50a76e03d') {
      return const SubjectNotesDetail(
        subjectId: '067159b7-ed17-4859-99e8-34d50a76e03d',
        subjectTitle: 'English',
        gradeLevel: 'Grade 12',
        totalChapters: 5,
        totalFileSize: '30 MB',
        downloadAllUrl:
            'https://kuta-learning.onrender.com/api/short-notes/eng/download-all',
        chapters: [
          ChapterNoteItem(
            id: 'chap-eng-1',
            chapterNumber: '1',
            title: '1. Advanced Reading Comprehension & Inference',
            description:
                'Critical reading strategies, analyzing author’s purpose, contextual vocabulary, and inference deduction.',
            pageCount: '15 Pages',
            fileSize: '2.8 MB',
            isCompleted: true,
          ),
          ChapterNoteItem(
            id: 'chap-eng-2',
            chapterNumber: '2',
            title: '2. Complex Sentence Structures and Syntax',
            description:
                'Conditional clauses, relative pronouns, subjunctive mood, parallel structures, and dangling modifiers.',
            pageCount: '17 Pages',
            fileSize: '3.3 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-eng-3',
            chapterNumber: '3',
            title: '3. Idiomatic Expressions and Collocations',
            description:
                'High-frequency academic collocations, phrasal verbs in context, and nuanced connotation distinctions.',
            pageCount: '14 Pages',
            fileSize: '2.7 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-eng-4',
            chapterNumber: '4',
            title: '4. Expository and Argumentative Writing',
            description:
                'Thesis formulation, persuasive paragraph transitions, counterarguments, and cohesive rhetoric.',
            pageCount: '20 Pages',
            fileSize: '4.0 MB',
            isCompleted: false,
          ),
          ChapterNoteItem(
            id: 'chap-eng-5',
            chapterNumber: '5',
            title: '5. Poetry, Prose and Literary Devices',
            description:
                'Metaphor, irony, symbolism, allegorical themes, narrative point-of-view, and literary analysis.',
            pageCount: '16 Pages',
            fileSize: '3.1 MB',
            isCompleted: false,
          ),
        ],
      );
    }

    // Default to Mathematics
    return const SubjectNotesDetail(
      subjectId: 'c0a82148-56d7-4475-a841-0df60b002729',
      subjectTitle: 'Mathematics',
      gradeLevel: 'Grade 12',
      totalChapters: 14,
      totalFileSize: '42 MB',
      downloadAllUrl:
          'https://kuta-learning.onrender.com/api/short-notes/math-12/download-all',
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
