# TriageLearn API — Week 1

Base path: `/api`

## Authentication

| Method | Endpoint | Auth | Purpose |
|---|---|---|---|
| POST | `/auth/register` | Public | Create a STUDENT account |
| POST | `/auth/login` | Public | Authenticate and set HttpOnly cookie |
| POST | `/auth/logout` | Public | Clear auth cookie |
| GET | `/auth/me` | Auth | Return current user and onboarding progress |

## Student progress

| Method | Endpoint | Role | Purpose |
|---|---|---|---|
| GET | `/progress` | STUDENT | XP, tier, onboarding state, recent attempts |

## Scenarios

| Method | Endpoint | Role | Purpose |
|---|---|---|---|
| GET | `/scenarios` | STUDENT/FACULTY | List permitted scenarios |
| GET | `/scenarios/:id` | STUDENT/FACULTY | Get scenario + patient data |
| POST | `/scenarios/:id/start` | STUDENT | Create a server-timestamped attempt |

## Planned P0 endpoints

`POST /scenarios/:id/interview`, `POST /scenarios/:id/vitals`, `POST /scenarios/:id/assessment`, `POST /scenarios/:id/triage`, `POST /scenarios/:id/routing`, `POST /scenarios/:id/complete`, `GET /leaderboard`, `GET /pretest`, `POST /pretest/answers`, `GET /posttest`, `POST /posttest/answers`, and faculty/report endpoints will be implemented in the remaining P0 slices.

### Rules

- Controllers validate input and delegate business logic.
- Server computes XP and score; clients never submit authoritative XP.
- Scenario elapsed time is validated against server timestamps.
- Clinical answers and feedback come from predefined database content.
- Faculty routes are read-only for gameplay and scoring data.
