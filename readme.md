# VX001
Project VX001 is a (baseline setup / bootstrapper) for future projects: fullstack web applications using MySQL, express, React, and Node.js.  Emphasis given to database setup using raw SQL, and Bash.

<br><br>



# Table of Contents
1. [Tech Stack](#tech-stack)
1. [Setup Procedure (Bootstrapping)](#setup-procedure)
    1. [Database](#database)
    1. [API](#api)
    1. [Client](#client)
1. [SKAR (Action Roster, To Do List)](#skar-action-roster)
1. [Commit History](#commit-history)
1. [Testing](#testing)
1. [Notes](#notes)

<br><br>



# Tech Stack
| Type | Choice | Comment |
| - | - | - |
| Hardware | Single, local PC |
| Main OS | Windows 11 |
| Virtual Machine (VM) | WSL2 (Debian) |
| Repo Type | Monorepo |
| Database Source Code | Raw SQL, Bash |
| Database Server | MySQL 8.0 Service | Running on Windows 11
| Frontend | React |
| JRE | Node.js | v22.17.0 (LTS)
| Backend | Node.js, express | 
| IaaS | [Railway](#railway.com) | DB, Fullstack deployment |
| Package Manager | nvm | v10.9.2 For per-project Node.js version management |

<br><br><br>




### Client

<br><br>



## SKAR (Action Roster)

### Raw AR
- [ ] refactor(db): move db .env into database directory
- [ ] bootstrap api
- [ ] refactor(db): cleanup comments
- [ ] fead(db): add comprehensive error handling and input validation
- [ ] feat(db): test --force, -f
- [ ] refactor(db): review DB_DEV_USER privileges
    - [ ] minimize db GRANTs for DB_DEV_USER
- [ ] refactor(db): move seed-clean logic into seed file
- [ ] docs(refactor): standardize commit table entires\
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

| Priority | Timeline | Item | Description |
| - | - | - | - |
| High | Later | feat(db): automate testing | unit-test? db/seed creation |
| High | Later | feat(db): automate a full test-restore | checksum, queries |
| Low | Later | feat(db-backup): show available backups | |
| Low | Later | feat(db-backup): make --tag, -t option | |
| Low | Later | feat(db-backup): allow -f option | |
| Low | Later | refactor(db): show_usage() | |
| Low | Later | feat(db-backup): test --force, -f | |

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
| - | [feat(api): prep dev environment, test api to db](#cm013) | 20250630a |
| x | [feat(db): review clean old backups function](#cm012) | 20250626a |
| x | [feat(db): review extras in data.sh, rev-d](#cm011) | 20250625a |
| x | [feat(db): review extras in data.sh, rev-c](#cm010) | 20250624a |
| x | [feat(db): review extras in data.sh, rev-b](#cm009) | 20250623a |
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

### CM013
```
feat(api): prep dev environment, test api to db

ENVIRONMENT
- Remove globals: Node.js, npm
- Install nvm to differentiate Node.js versions per project
- Setup Node.js LTS for VX001 using .nvmrc-file
- Create and run `setup-api.sh`
    - Installs dependencies
    - Initializes configuration files

API
- API Core: ./api/index.js
- ORM (Sequelize) Configuration: ./api/config/db.js
- Environment Variable Map: ./api/config/env.js
- Test database connection
```

### CM012
```
feat(db): review clean old backups function

- Review / Repair `[REV-E]` section(s)
- [x] cleanup_old_backups()

vibe-coded-with: Claude
reason: SQL, Bash practice
```

### CM011
```
feat(db): review extras in data.sh, rev-d

- Review / Repair `[REV-D]` sections
- [x] inspect_backup_file()

vibe-coded-with: Claude
reason: SQL, Bash practice
```

### CM010
```
feat(db): review extras in data.sh, rev-c

- Review / repair `[REV-C]` sections

Fixed 
- [x] list_backups()
- [x] show_backup_info()

vibe-coded-with: Claude
reason: SQL, Bash practice
```

### CM009
```
feat(db): review extras in data.sh, rev-b

`data.sh` (data-management script) handles backup and
and restore, and was originally vibe-coded with Claude AI which
included many unexpected, useful, yet buggy features.  Most extra
features were ignored and untested in last commit.  This commit
continues review and bug fixes.

- Review / repair `[REV-B]` sections
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

<br><br>



## Testing

### Database Testing Notes
- [ ] `--force`, `-f` on `restore`

<br><br>



## Notes

### Verify Backup (Database)
- '"Gold Standard" is a **full restore** to a separate, isolated environment (e.g. a test server), *then*
- Running tests / integrity checks' -Google Gemini

<br><br>

