# VX001 Devlog

## Table of Contents
1. [Commits](#commits)
1. [July 2025](#july-2025)

<br><br><br>




## Commits

| x | Message Title | YYYYMMDDn |
| - |:- |:- |
| - | [feat(api): update err: validateUserCreate](#cm024) | ? |
| x | [feat(api): update err: GET-users/:id](#cm023) | 20250710b |
| x | [feat(app): update err: validateUserId](#cm022) | 20250710a |
| x | [docs(all): restructure documentation](#cm021) | 20250709a |
| x | [feat(api): add user validation](#cm020) | 20250708a |
| x | [feat(api): add error handling](#cm019) | 20250707a |
| x | [feat(web): normalize styles](#cm018) | 20250707a |
| x | [feat(db): rename password_hash > password](#cm017) | 20250706b |
| x | [refactor(web): add Home, Test routes](#cm016) | 20250706a |
| x | [feat(web): create React app, test user routes](#cm015) | 20250701a |
| x | [feat(api): create basic user model and routes](#cm014) | 20250630b |
| x | [feat(api): prep dev environment, test api to db](#cm013) | 20250630a |
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

### CM025
```
feat(api): update err: POST-api/users route

- update (create-user)/(POST-api/users) route
    - Location: api/routes/user-routes.js
- use error format RFC7807
- Test: manually disable web-validation to hit API-validation layer
```

### CM024
```
feat(app): update err: validateUserCreate mw

- update validateUserCreate
    - Location: api/middleware/validation.js
- use error format RFC7807
- update createUser to display new format
    - Location: web/src/pages/Test.jsx
- Test: manually disable web-validation to hit API-validation layer
```

### CM023
```
feat(api): update err: GET-users/:id

- update GET-users/:id route error format to RFC7807

Also:
- refactor(api): modify error handler log
```

### CM022
```
feat(app): update err: validateUserId

- update validateUserId-middleware with new error format
- choose a normalized error format: RFC7807
- update web Test.jsx page to display new format

Also:
- docs(all): continue improving doc structure
```

### CM021
```
docs(all): restructure documentation
```

### CM020
```
feat(api): add user validation

- Create api/middleware/validation.js to
    - export validateUserCreate, validateUserUpdate, validateUserId

Modify:
- api/routes/user-routes.js: use validation middleware
- api/ops/api-test.sh: change password to match validation rules
- web/src/pages/Test.jsx: change password to match validation rules
```

### CM019
```
feat(api): add error handling

Add server-side error handling

- Create api/middleware/error-handler.js to
    - export errorHandler
    - export asyncHandler
- Create api/ops/api-test.sh

Modify:
- api/routes/user-routes.js
- api/index.js

claude-coded: api-test.sh
```

### CM018
```
feat(web): normalize styles

Homepage-text blended in with background.  Need to reset CSS globally.

- remove inline styling
- add styles-directory to include files:
    - global.css
    - normalize.css
```

### CM017
```
feat(db): rename password_hash > password

- Change migration and seed
- See devlog AR001
```

### CM016
```
refactor(web): add Home, Test routes

Additional changes:
- refactor(web): add react-router-dom
- refactor(web, api): use password vs password_hash
    - [pending: db not yet updated. see devlog AR001.]
- refactor(api): refactor env-var importing
```

### CM015
```
feat(web): create React app, test user routes

ENVIRONMENT
- Creat project using Vite and modify configuration
    - Most directories and files automatically generated by Vite
- Install axios

WEB-CLIENT
- Modify: 
    - web/src/App.jsx
    - web/src/App.css
```

### CM014
```
feat(api): create basic user models and routes

- Create folders:
    - ./api/routes
    - ./api/models
- Create user files:
    - ./api/routes/user-routes.js
    - ./api/models/Users.js
- Test with Postman

Also:
refactor(db): add filenames to migration files
```

### CM013
```
feat(api): prep dev environment, test api to db

ENVIRONMENT
- Remove globals: Node.js, npm
- Install nvm to differentiate Node.js versions per project
- Setup Node.js vLTS (v22.17.0) for VX001 using .nvmrc-file
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

<br><br><br>




## July 2025

### Friday, July 11, 2025
20250710

- Working on updating error format for `validateUserCreate`
- [ ] change GET-all route to `api/users/all`
    - else `api/users/` = get user by id with id input blank
- [ ] Create a form-validation toggle in web for testing api error-check

### Thursday, July 10, 2025
20250710

- Decided to follow RFC 7807 error response format
- First updated only a single resilience target with RFC7807:
    - `validateUserId`-middleware
- Updated web-client to handle new format
- Updated `GET users/:id` route: Non-existent user error

#### Commits
- [feat(api): update err: GET-users/:id](#cm023)
- [feat(app): update err: validateUserId](#cm022)

#### Next
[feat(api): update err: validateUserCreate](#cm024)

### Wednesday, July 9, 2025
20250709

#### Commits
- [docs(all): restructure documentation](#cm021)