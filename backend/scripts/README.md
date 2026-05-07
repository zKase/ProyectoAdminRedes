Create admin user

This folder contains a small script to generate an SQL INSERT for an admin user.

Usage:

1. From the repo root run:

   node backend/scripts/create-admin.js

2. This generates `backend/scripts/create-admin.sql` with an INSERT statement including a bcrypt-hashed password.

3. Execute the SQL against your Postgres database (psql or any SQL client). Example:

   psql -h <host> -U <user> -d <db> -f backend/scripts/create-admin.sql

Default credentials written to the SQL: admin@example.com / Password123!
