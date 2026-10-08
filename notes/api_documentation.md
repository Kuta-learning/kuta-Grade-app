# API Documentation Guide (Contracts & Endpoints)

This document outlines the API endpoints and contracts expected by the application. Actual network implementations will use these structures.

## Base URL
- Staging: `https://api-staging.kuta.app/v1`
- Production: `https://api.kuta.app/v1`

---

## 1. Authentication Endpoints

### `POST /auth/login`
**Request Body:**
```json
{
  "email": "user@kuta.app",
  "password": "secure_password"
}
```
**Response (200 OK):**
```json
{
  "accessToken": "eyJhbGciOi...",
  "refreshToken": "eyJhbGciOi...",
  "user": {
    "id": "u_987",
    "name": "Chala Desta",
    "email": "user@kuta.app",
    "gradeLevel": "grade_8", // "kg" | "grade_6" | "grade_8" | "grade_12"
    "avatarUrl": "https://cdn.kuta.app/avatars/u_987.png"
  }
}
```

---

## 2. Learning & Curriculum Endpoints

### `GET /curriculum/subjects?grade={grade_level}`
Returns the list of enrolled subjects for a given grade level (Grade 6, 8, 12).

### `GET /curriculum/subjects/{subjectId}/chapters`
Returns chapters and topics for a selected subject.

### `GET /kg/activities`
Returns interactive activities, audio stories, and visual games for Kindergarten learners.

### `POST /progress/update`
Syncs student study progress, quiz scores, and milestones.
