# TriageLearn — PHP/XAMPP Build

This directory is the accelerated PHP/MySQL implementation of TriageLearn. The original PERN implementation remains in `client/` and `server/` on this feature branch as a reference.

## Stack
- PHP 8.x + PDO
- MySQL/MariaDB through XAMPP
- HTML5/CSS3
- Vanilla JavaScript + Fetch API
- PHP Sessions + `password_hash()` / `password_verify()`
- phpMyAdmin for database administration

## Run locally
1. Install XAMPP and start Apache + MySQL.
2. Copy this repository into `xampp/htdocs/TriageLearn`.
3. Open phpMyAdmin and import `xampp-app/database/schema.sql`.
4. Set `BASE_URL` in `xampp-app/config/config.php` to match the folder name.
5. Open `/TriageLearn/xampp-app/public/` in the browser.

## Architecture
`public/` contains page controllers and API endpoints. `includes/` contains authentication/security helpers. `config/` owns the database connection. Clinical scenario content is stored in MySQL and loaded by scenario ID so one reusable scenario engine can support all project scenarios.

## Features in this foundation
- PHP session authentication foundation
- Role-aware access helpers for STUDENT/FACULTY
- CSRF protection for form actions
- Prepared PDO statements
- Tier-gated scenario dashboard
- Server-created scenario attempts
- Scenario timer UI
- JSON endpoint for Fetch/AJAX scenario loading
- Centralized performance-rating helper

## Important
Do not copy the demo clinical data into production. Replace it with project-owner-approved and clinically validated educational content. The application should present predefined content; it should not dynamically generate clinical triage decisions.
