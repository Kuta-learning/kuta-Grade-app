# Authentication & Dynamic Routing Documentation

## Overview
All users of Kuta Learning App log in through a single, unified entry point. There are no separate login portals for different grades.

Once authenticated, the application inspects the user's profile metadata (`studentGradeLevel` / `role`) and dynamically routes the user to the appropriate experience.

---

## Grade & Role Resolution

```
User logs in (Email & Password / Social / SSO)
        │
        ▼
Backend returns User Auth Payload:
{
  "id": "usr_12345",
  "name": "Abebe Kebede",
  "email": "student@kuta.app",
  "token": "jwt_...",
  "gradeLevel": "kg" | "grade_6" | "grade_8" | "grade_12"
}
        │
        ▼
App Router evaluates `gradeLevel`:
  ├── "kg"        ➜ Route to `RouteNames.kgHome`
  ├── "grade_6"   ➜ Route to `RouteNames.gradeDashboard` (arg: GradeLevel.grade6)
  ├── "grade_8"   ➜ Route to `RouteNames.gradeDashboard` (arg: GradeLevel.grade8)
  └── "grade_12"  ➜ Route to `RouteNames.gradeDashboard` (arg: GradeLevel.grade12)
```

---

## Rationale for Shared vs. Separate Experiences

| Audience | Design System | Experience Characteristics | Implementation Path |
| :--- | :--- | :--- | :--- |
| **KG** | **Distinct Child UI** | Audio-heavy, character illustrations, oversized buttons, gamified touch UI | `lib/features/kg/` |
| **Grade 6** | **Shared Unified UI** | Subject cards, chapter lists, reading views, interactive quizzes | `lib/features/grades/shared/` & `grade_6/` |
| **Grade 8** | **Shared Unified UI** | Same as Grade 6 + regional exam prep & mock tests | `lib/features/grades/shared/` & `grade_8/` |
| **Grade 12**| **Shared Unified UI** | Same as Grade 6/8 + university entrance exam prep & timed tests | `lib/features/grades/shared/` & `grade_12/` |
