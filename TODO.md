# SKAR
(Strategic Kommand Action Roster) HAVOK-branded todo list.

## Table of Contents

## Roadmap
- [P] Normalize error messages across API
- [ ] Add JWT authentication (register/login/logout)
- [ ] Create frontend auth components
- [ ] Protect private routes (API + frontend)
- [ ] Add generic `entries` table for content
- [ ] Create deployment scripts
- [ ] Write comprehensive README
- [ ] Document API endpoints
- [ ] Add setup/installation guide
- [ ] Final testing and cleanup

### Complete
- [x] Initialize database with migrations/seeds/backups
- [x] Initialize API with user model and routes
- [x] Initialize web client with React/routing
- [x] Initialize error handling
- [x] Initialize validation middleware
- [x] Pass E2E tests for user model

### SKAR
- [ ] Advanced validation (email format, password strength, etc.)
- [ ] create system for client error display
- AR004 - feat(web): basic client-side validation (CM020)
- [ ] integrate host into error type URI
- [ ] upgrade global error catcher
- [ ] feat(e2e): add password_hash
- [ ] refactor(db): rename nodes to entities?
- [ ] refactor(db): cleanup comments
- [ ] feat(db): test --force, -f
- [ ] feat(db): finalize error handling and input validation
- [ ] refactor(db): review DB_DEV_USER privileges
    - [ ] minimize db GRANTs for DB_DEV_USER
- [ ] refactor(db): move seed-clean logic into seed file
- [ ] docs(refactor): standardize commit table entires\
- [ ] `reset.sh`? option in seed file
- [ ] update migration script: `.my.cnf`, migration_user?
- [ ] create `utils.sh` for common functions
    - See "[MOVE] Move to `utils.sh`"
- [ ] add db validation checks to scripts
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
- [ ] (!) feat(all): allow for repeated usernames by adding a random # to end of username

1. Validation Build Plan (Step-by-Step)
- [ ] add client-side validation (form validation)
- [ ] Error handling and user feedback
1. Authentication

| Priority | Timeline | Item | Description |
| - | - | - | - |
| High | Later | ?(api): review api-test.sh
| High | Later | feat(db): automate testing | unit-test? db/seed creation |
| High | Later | feat(db): automate a full test-restore | checksum, queries |
| Med  | Later | docs(e2e): implement an automated doc system | |
| Low  | Later | feat(db-backup): show available backups | |
| Low  | Later | feat(db-backup): make --tag, -t option | |
| Low  | Later | feat(db-backup): allow -f option | |
| Low  | Later | refactor(db): show_usage() | |
| Low  | Later | feat(db-backup): test --force, -f | |

### Complete SKAR Items
- [x] feat(db): add basic error handling and input validation
- [x] 1. add validation middleware
    - feat(web): add input validation, error handling
- [x] refactor(api): use camel case for route-files? NO. kebab-case.file
- [x] AR003 - feat(api): basic server-side validation (CM019)
- [x] AR002 - feat(web): normalize css (CM018)
- [x] AR001 - feat(db): use password vs password_hash (CM017)

### Deployment AR
- [ ] input validation and error handling
- [ ] credential security best practices
- [ ] file permission recommendations
- [ ] SQL/JS injection prevention
- [ ] recovery procedures

### Technical Debt
- [ ] POSIX-safety?
    - `migrate.sh`

    ## Basic Validation
1. Add `BrowserRouter` to `web/src/main.jsx`
1. Create basic routes in `web/src/Routes.jsx`
1. Create `web/scr/components/`: `Home.jsx`, `Test.jsx`
1. Update `web/src/App.jsx` with `<AppRoutes />` and links to components

## Global Error Handling

## Authentication

## Database Relationship Management