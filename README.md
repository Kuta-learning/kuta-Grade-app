# Kuta Learning App

A Flutter-based learning platform supporting **Kindergarten (KG)**, **Grade 6**, **Grade 8**, and **Grade 12** students.

---

## Architecture

This project is built using a **Feature-First Architecture**:

```
lib/
├── app.dart                  # Top-level MaterialApp configuration
├── main.dart                 # Application entrypoint
├── core/                     # Globally shared foundations
│   ├── constants/            # App constants, routes, API endpoints, grade level enum
│   ├── localization/         # Localization and language support
│   ├── router/               # Navigation definitions and route generator
│   ├── storage/              # Persistent key-value / secure storage contracts
│   ├── theme/                # Colors, typography, and Material theme definitions
│   ├── utils/                # Validators and formatters
│   └── widgets/              # Universal shared UI components
└── features/                 # Self-contained business domains
    ├── authentication/       # Unified login, splash, and auth routing
    ├── common/               # Shared learning models and widgets
    ├── kg/                   # Independent Kindergarten learning experience
    ├── grades/               # Shared structure for Grades 6, 8, and 12
    │   ├── shared/           # Shared models, screens, and widgets for Grades 6/8/12
    │   ├── grade_6/          # Grade 6 specific screens and widgets
    │   ├── grade_8/          # Grade 8 specific screens and widgets
    │   └── grade_12/         # Grade 12 specific screens and widgets
    └── profile/              # User profile, account, and preferences
```

---

## Documentation

Comprehensive project documentation is maintained in the [`notes/`](notes/) folder:
- [Architecture Overview](notes/architecture.md)
- [Authentication & Dynamic Routing](notes/authentication_and_routing.md)
- [API Documentation](notes/api_documentation.md)
- [Implementation Guidelines](notes/implementation_notes.md)
# kuta-learning-app
Before starting a new task, developers must always pull the latest updates from the `development` branch. Each feature needs its own branch named `feature/<feature-name>` (like `feature/login-page`). Once finished, open a Pull Request into the `development` branch, where only the team lead will review and merge it.
