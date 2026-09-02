# TriageLearn — Week 1 Architecture

## Stack

- PostgreSQL: authoritative relational data and transaction boundaries.
- Express + Node.js: REST API, authentication, authorization, server-side progression rules.
- React + Vite: data-driven UI.
- `pg`: parameterized SQL; no ORM is required for the MVP.

## Request flow

```text
React UI
  │ credentials: include
  ▼
Express API
  ├── Helmet / CORS / JSON / rate limit
  ├── Auth middleware (HttpOnly JWT cookie)
  ├── Role middleware (STUDENT / FACULTY)
  ├── Controllers (HTTP only)
  └── PostgreSQL services/data access
           │
           ▼
      PostgreSQL
```

## Scenario architecture

The UI will use one reusable scenario engine. Scenario-specific clinical facts live in PostgreSQL rather than in React branches.

```jsx
const scenario = await getScenario(id);
return <ScenarioEngine scenario={scenario} />;
```

The Week 1 `ScenarioPage` is the entry shell. Interview, vitals, assessment, ESI, routing, scoring and feedback actions are intentionally added as later P0 slices.

## Security decisions

- Passwords are hashed with bcrypt.
- JWTs are stored in an HttpOnly cookie rather than localStorage.
- Role and identity come from the server-side verified JWT and database, not request-body fields.
- PostgreSQL queries use parameters.
- Authentication endpoints are rate limited.
- Helmet and CORS are enabled.
- XP is not accepted from the client; the future XP service will calculate ledger entries server-side.

## Progression configuration

Tier 1 is initially unlocked. Tier 2/3 thresholds remain configurable because the project proposal contains competing threshold examples. Current UI config mirrors the proposal examples: Tier 2 = 200 XP and Tier 3 = 224 XP. These are product configuration values, not clinical rules.

## Clinical-content boundary

The repository contains only an explicitly marked technical demo seed. It is not educational/clinical content and must be replaced with project-owner-approved and validated content before student deployment. No AI/LLM is used to generate or classify clinical decisions.

## Week 1 acceptance slice

- PostgreSQL schema can be created with `npm run db:setup`.
- Express health endpoint exists.
- Student registration creates a user and progress row atomically.
- Login/logout/me work through an HttpOnly JWT cookie.
- Protected routes enforce authentication and roles.
- Student dashboard reads XP/tier/progress from the server.
- Scenario list/detail/start are API-driven.
- Starting a scenario creates a server-timestamped attempt.
- React has a reusable scenario entry shell ready for the next gameplay slice.
