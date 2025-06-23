# VX001
Project VX001 is a baseline setup for a fullstack web application using MySQL, express, React, and Node.js.  Emphasis given to database setup using raw SQL.

# Table of Contents
1. [Stack](#stack)
1. [Setup](#setup)
1. [SKAR](#skar-action-roster)
1. [Database](#database)
1. [Commit History](#commit-history)
1. [Testing]

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
- [ ] feat(db): test --force, -f
- [ ] refactor(db): review DB_DEV_USER privileges
    - [ ] minimize db GRANTs for DB_DEV_USER
- [ ] refactor(db): move seed-clean logic into seed file
- [ ] feat(db): implement metadata for db backups
- [ ] feat(db): test `cleanup` and `KEEP_DAYS`
- [ ] docs(refactor): standardize commit table entires
- [ ] create a test / unit-test? to verify proper db and seed-data creation
- [ ] `reset.sh`? option in seed file
- [ ] update migration script: `.my.cnf`, migration_user?
- [ ] create `utils.sh` for common functions
    - See "[MOVE] Move to `utils.sh`"
- [ ] add validation checks to scripts
- [ ] decide on local-file backup system.  backup old files.
- [ ] separate database and user creation in database scripts
- [ ] clean setup & teardown scripts to remove non-root user
- [ ] create, test node table migration script. sql practice.
- [ ] seed database
- [ ] practice JOINs and QUERYs? how?
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

### Low Priority
- [ ] feat(db-backup): show available backups
- [ ] feat(db-backup): make --tag, -t option
- [ ] feat(db-backup): allow -f option

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
| _ | [feat(db): review extras in data.sh, rev-b](#cm009) | 20250623a |
| x | [feat(db): implement db backup and restore](#cm008) | 20250620a |
| x | [feat(db): implement seed files](#cm007) | 20250620a |
| x | [fix(db): run migrations in ascending order](#cm006) | 20250619c |
| x | [refactor(db): normalize migration filenames](#cm005) | 20250619b |
| x | [feat(db): create nodes table. M0002](#cm004) | 20250619a |
| x | [feat(db): add rollback](#cm003) | 20250618a |
| x | [refactor(db): add table-check for migration](#cm002) | 20250618a |
| x | [refactor(db): make admin temporary, create roles](#cm001) | 20250614a |
| x | create, reset:  user table, migration table, migration script. sql practice. | 20250613a |
| x | create & test database setup, teardown scripts. sql practice. | 20250612a |

### CM009
```
feat(db): review extras in data.sh, rev-b

`data.sh` is a data-management script that was to handle backup and
and restore.  It was vibe-coded with Claude AI which included many
unexpected, useful, yet buggy features.  Most extra features were
ignored and untested in last commit.  This commit is for continuing
review and fixing bugs.

- Reviewed / repaired `[REV-B]` sections
- Replace `create_backup_directory()` with inline, idempotent 
    `mkdir -p` in `create_backup()`

vibe-coded-with: Claude
reason: SQL, Bash practice
```

### CM008
```
feat(db): implement db backup and restore

Automated backup and restore only works with a single file: bak.sql
- Backup appends information to `backup.log`
- Backup creates `./database/backups/metadata/`DATE_TIME.json`
- Backup creates a `bak_DATE_TIME.sql` file along with a copy
    that overwrites `bak.sql`
- Restore *ONLY* looks at `bak.sql`, and does *NOT* access log nor
    metadata

Notes:
- `data.sh` vibe-coded with Claude AI, but too many extra features
    were implemented at once introducing too many bugs
- Commented out or not using many extra features to keep debugging
    simple and focused on just a basic backup/restore

Also:
docs(readme): normalize number of digits in commit history numbers

vibe-coded-with: Claude
reason: SQL practice
```

### CM007
```
feat(db): implement seed files

- Create files:
    - `001__users.seed.sql`
    - `002__nodes.seed.sql`
    - `clean.sql`
    - `seed.sh`
- Test seed, clean, seed sequence

Reason: SQL practice
```

### CM006
```
fix(db): run migrations in ascending order

- Migrations are currently running non-deterministically
- Use migration filename prefixes to order migrations

Also:
docs(readme): correct commit history table
- add previous commit title to commit history table
```

### CM005
```
refactor(db): normalize migration filenames

- Start using a double-underscore after the numeric-prefix
in migration filenames instead of a single-underscore.
- Change filenames and code accordingly
```

### CM004
```
feat(db): create nodes table. M0002

- Create files:
    - `0002__create_nodes_table.up.sql`
    - `0002__create_nodes_table.down.sql`
- Manually test that multiple migrations work as expected:
    - Migrate up from migration 0 to 2
    - Rollback from 2 to 0
    - Migrate up to 2 again

Fix: Selecting last migration via executed_at(TIMESTAMP) was not
    deterministic.  Switched to selecting last migration using file
    prefixes.

Reason: SQL practice
```

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
- Test only a single migration: `0001__create_users_table`

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

## Testing

### Database Testing Notes
- [ ] `--force`, `-f` on `restore`