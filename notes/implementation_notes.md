# Implementation Notes for Developers

## 1. Feature-First Folder Rules

When creating or modifying features:
1. **Locality of Behavior**: Put screens, private widgets, and domain models inside the respective feature folder.
2. **When to promote to `core/`**: Only promote a component to `core/` if it is genuinely shared across different top-level domains (e.g. both Authentication and KG and Grades).
3. **When to use `features/grades/shared/`**: UI components like `SubjectCard`, `ChapterTile`, `QuizWidget` should be placed in `features/grades/shared/` because they apply to Grades 6, 8, and 12.
4. **When to use grade-specific folders**: Put exam-specific or curriculum-specific variations in `features/grades/grade_6/`, `grade_8/`, or `grade_12/`.
5. **KG Isolation**: KG components must never import from `features/grades/`. KG has an independent UI language, sound engine, and design system.

---

## 2. Naming Conventions

- **Files**: `snake_case.dart` (e.g., `login_screen.dart`, `subject_card.dart`).
- **Classes**: `PascalCase` (e.g., `LoginScreen`, `SubjectCard`).
- **Variables & Functions**: `camelCase` (e.g., `getUserProfile()`, `gradeLevel`).
- **Constants**: `camelCase` or `kCamelCase` (e.g., `kDefaultPadding`, `primaryColor`).

---

## 3. Recommended State Management

When business logic is added later:
- Recommended: **Bloc / Cubit** or **Riverpod**.
- Store feature states within `features/<feature_name>/bloc/` (or `controllers/` / `providers/`).
- Keep presentation widgets stateless where possible and drive state through reactive providers/cubits.
