# VX001
Project VX001 is a baseline setup for a fullstack web application using MySQL, express, React, and Node.js.  Emphasis given to database setup using raw SQL.

# Table of Contents
1. [Stack](#stack)
1. [Setup](#setup)
1. [SKAR](#skar-action-roster)
1. [Database](#database)
1. [Commit History](#commit-history)

## Stack
| Type | Choice | Comment |
| - | - | - |
| Hardware | Single, local PC |
| Main OS | Windows 11 |
| Virtual Machine (VM) | WSL2 (Debian) |
| Database Source Code | Raw SQL, Bash |
| Database Server | MySQL 8.0 Service | Running on Windows 11
| Frontend | React |
| Backend | Node.js, express |
| IaaS | [Railway](#railway.com) | DB, Fullstack deployment |

# Setup
[Return to Table of Contents](#table-of-contents)

## Database
1. Install MySQL Workbench onto Windows 11, including CLI tools?
1. `root`-user and password should be created during setup-wizard
   - Keep `root`'s `From Host` as `localhost` 
   - `root` will only be able to connect / login from Windows *ONLY*, not from WSL2 or anywhere else, intentionally, for security
   - Use `root` only for initialization, and distaster-recovery
1. Login to MySQL Workbench as `root`, create an `admin`-user who will act like a `root`-user, but with ability to sign-in from non-`localhost` IP addresses (e.g. WSL2).
    - Set "From Host" = {An IP range that includes the WSL2 IP address as seen from (Windows / MySQL Service) }
1. Ensure that `admin` and password are set in `vx001/database/ops/.env.init`.
1. `init.sh` will create user roles `dev`, and `app` and passwords.
1. Ensure that `dev` and `app` passwords are properly set in `vx001/.env`
1. `admin`-user should not be needed any more.  You can delete `.env.init`.

# SKAR (Action Roster)
- [ ] `seed.sh`
- [ ] create a test / unit-test? to verify proper db and seed-data creation
- [ ] `clean.sh`
- [ ] `rollback.sh`
- [ ] `reset.sh`
- [ ] update migration script: `.my.cnf`, migration_user?
- [ ] add validation checks to scripts
- [ ] decide on local-file backup system.  backup old files.
- [ ] separate database and user creation in database scripts
- [ ] clean setup & teardown scripts to remove non-root user
- [ ] create, test node table migration script. sql practice.
- [ ] seed database
- [ ] practice JOINs and QUERYs? how?
- [ ] `backukp.sh`
- [ ] `restore.sh`
- [ ] constraints and validation
- [ ] indexing
- [ ] triggers?
- [ ] unit testing and qa
- [ ] security hardening
    - [ ] process visibility - password shows up in process lists when mysql runs
    - [ ] file permissions - .env files are often readable by multiple users
    - [ ] root access is overprivileged for migrations
- [ ] advanced: replication, high-availability
- [ ] verify users and global priviliges removed
- [ ] refine tables, columns
- [ ] review validations
- [ ] update `dev_rca` user to have migration privileges only or create a migration only user?

### Deployment AR
- [ ] input validation and error handling
- [ ] credential security best practices
- [ ] file permission recommendations
- [ ] SQL/JS injection prevention
- [ ] recovery procedures

### Technical Debt
- [ ] POSIX-safety?
    - `migrate.sh`

## Commit History
[Return to Table of Contents](#table-of-contents)

| x | Message Title | YYYYMMDDn |
| - |:- |:- |
| _ | [feat(db): add rollback](#cm003) | 20250618a |
| x | [refactor(db): add table-check for migration](#cm002) | 20250618a |
| x | [refactor(db): make admin temporary, create roles](#cm001) | 20250614a |
| x | create, reset:  user table, migration table, migration script. sql practice. | 20250613a |
| x | create & test database setup, teardown scripts. sql practice. | 20250612a |

### CM003
```
feat(db): add rollback

- Add `rollback_last_migration()` to `migrate.sh`
- Remove `rollback/`-directory
- Keep both up/down migrations in `ops/migrations/` using
    `*.[direction].sql` suffixes

Reason: SQL practice
```

### CM002
```
refactor(db): add table-check for migration

This is a complete overhaul of the migration-script.

ORIGINAL: Blindly apply all migrations found in the migrations-folder
using the `migrate()`-function.
NEW: Check the migrations table

- Remove `migrate()` from `migrate.sh`
- Add:
    - `check_migrations_table()`
    - `run_migration()`
    - `run_all_pending_migrations()`
    - `show_usage()`
- Test only a single migration: `0001_create_users_table`

Reason: SQL practice
```

### CM001
Commit message 1. Testing the Conventional Commit format.
```
refactor(db): make admin temporary, create roles

During one-time database-intialization, make the ADMIN-user data
temporary by using it only in the disposable `.env.init` located in
`./database/ops`.
Create db-user roles: DEV & APP.
Test database reset.

Reason: SQL practice
```