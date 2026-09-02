# TriageLearn

Gamified web-based ESI triage learning system for nursing students.

## Week 1 foundation

PERN stack monorepo with:
- PostgreSQL schema and seed data
- Express REST API
- JWT authentication and role authorization
- React/Vite client
- Student first-login flow scaffold
- Data-driven scenario API and reusable scenario engine scaffold

## Clinical-content note
Clinical classifications, findings, vital signs, routing, and feedback are represented as predefined database content. Replace seed clinical examples with project-owner-approved/validated content before educational deployment.

## Development

1. Copy `server/.env.example` to `server/.env` and configure PostgreSQL/JWT values.
2. `cd server && npm install && npm run db:setup && npm run dev`
3. `cd client && npm install && npm run dev`

See `docs/week-1-architecture.md` for the architecture and implementation plan.
