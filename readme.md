# VX001
A baseline setup for fullstack web applications

# Table of Contents
1. [Stack](#stack)
1. [Database](#database)

## Stack

### Development

#### Hardware
Single, local PC.

#### Software

| Type | Choice |
| - | - | 
| Main OS | Windows 11 |
| Virtual Machine (VM) | WSL2 (Debian) |
| Database Source Code | Raw SQL |
| Database Server | MySQL 8.0 Service on Windows 11 |
| Frontend | React |
| Backend | Node.js, express |

### Deployment

#### Services
- [railway.com](#railway.com)

# SKAR (Action Roster)
- [ ] refactor for non-root user/pass: `setup.sh`, `destroy.sh`, `.env`
- [ ] update `dev_rca` user to have limited privileges or create a migration only user?
- [ ] `seed.sh`
- [ ] create a test / unit-test? to verify proper db and seed-data creation
- [ ] `clean.sh`
- [ ] `rollback.sh`
- [ ] `reset.sh`
- [ ] update migration script: `.my.cnf`, migration_user
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
- [ ] advanced: replication, high-availability
- [ ] verify users and global priviliges removed
- [ ] refine tables, columns
- [ ] review validations

# Database
[Return to Table of Contents](#table-of-contents)

# Commit History
[Return to Table of Contents](#table-of-contents)

| x | Message | YYYYMMDDn |
| - | - | - |
| x | create & test database setup, teardown scripts. sql practice. | 20250612a |
| x | create, reset:  user table, migration table, migration script. sql practice. | 20250613a |