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
   - `root` will only be able to connect / login from Windows *ONLY* not from WSL2 or anywhere else, intentionally for security
   - Use `root` only for initialization, and distaster-recovery
1. Login to MySQL Workbench as `root`, create an `admin`-user who will act like a `root`-user, but with ability to sign-in from non-`localhost` IP addresses (e.g. WSL2).
    - Set "From Host" = {An IP range that includes the WSL2 IP address as seen from (Windows / MySQL Service) }
1. Ensure that `admin` and password are set in `vx001/database/ops/.env.init`.
1. `init.sh` will create user roles `dev`, and `app` and passwords.
1. Ensure that `dev` and `app` passwords are properly set in `vx001/.env`
1. `admin`-user should not be needed any more.  You can delete `.env.init`.

# SKAR (Action Roster)
- [ ] refactor(db): make root temporary, create roles
- [ ] update `dev_rca` user to have migration privileges only or create a migration only user?
- [ ] `seed.sh`
- [ ] create a test / unit-test? to verify proper db and seed-data creation
- [ ] test git's extended comment option `-m "..." -m "..."` or file upload?
- [ ] `clean.sh`
- [ ] `rollback.sh`
- [ ] `reset.sh`
- [ ] update migration script: `.my.cnf`, migration_user
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

### Deployment AR
- [ ] input validation and error handling
- [ ] credential security best practices
- [ ] file permission recommendations
- [ ] SQL/JS injection prevention
- [ ] recovery procedures

# Commit History
[Return to Table of Contents](#table-of-contents)

| x | Message Title | YYYYMMDDn |
| - |:- |:- |
| x | create & test database setup, teardown scripts. sql practice. | 20250612a |
| x | create, reset:  user table, migration table, migration script. sql practice. | 20250613a |
| _ | [refactor(db): make admin temporary, create roles](#cm001) | 20250614a |

## CM001
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