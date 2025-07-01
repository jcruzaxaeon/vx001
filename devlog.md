# Devlog - VX001

# Table of Contents
1. [Commit History](#commit-history)
1. [SKAR (Action Roster)](#skar-action-roster)
1. [Project Notes](#project-notes)
1. [Setup Procedure](#setup-procedure)
1. [AI Prompts](#ai-prompts)
    1. [Question List](#question-list)
    1. [API Bootstraping](#api-bootstraping)

<br><br><br>




## Commit History
[Return to Table of Contents](#table-of-contents)

| x | Message Title | YYYYMMDDn |
| - |:- |:- |
| x | [feat(api): create basic user models and routes](#cm014) | 20250630b |
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




## SKAR (Action Roster)
[Return to Table of Contents](#table-of-contents)

### Raw AR
- [ ] refactor(api): use camel case for route-files?
- [ ] refactor(db): rename nodes to entities?
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

<br><br><br>




## Project Notes
[Return to Table of Contents](#table-of-contents)

### Monorepo File Structure
```
project/
    api/
        config/
            db.js
            env.js
        index.js
        setup-api.sh
        .env                       #API only
    database/
        backups/
        migrations/
        ops/
        seeds/
        .env                       #DB only
    web/
        .env                       #Web only
    .env                           #Globals
```

<br><br><br>




# Setup Procedure
[Return to Table of Contents](#table-of-contents)

## Database
1. Enable WSL2 on Windows 11.
1. Install MySQL Workbench onto Windows 11, including CLI tools?
1. `root`-user and password should be created during setup-wizard
   - Keep `root`'s `From Host` as `localhost` 
   - `root` will be able to (connect / login) from Windows *ONLY*, not from WSL2 or anywhere else, intentionally, for security
   - Use `root` only for initialization, and distaster-recovery
1. Login to MySQL Workbench as `root`, create an `admin`-user who will act like a `root`-user, but with ability to sign-in from non-`localhost` IP addresses (e.g. WSL2).
    - Set "From Host" = {An IP range that includes the WSL2 IP address as seen from (Windows / MySQL80 Service) }
1. Ensure that `admin` and password are set in `vx001/database/ops/.env.setup`.
1. ( [ ] "Missing steps" ) Run ` $ ./setup.sh` to create user roles `dev`, and `app`.
1. Ensure that `dev` and `app` passwords are properly set in `vx001/.env`
1. `admin`-user should not be needed any more.  You can delete `.env.setup`.

## API

### Install `nvm`
Use `nvm` to run different versions of `Node.js` for each per project.
1. If you currently have `Node.js` and/or `npm` installed globally, and have other projects that depend on them, take note of the `Node.js` version:
    ```sh
    $ node --version
    ```
1. Uninstall both `Node.js`, and `nvm`:
    > ⚠️ This removal will break any existing projects that depend on your globally installed version of `Node.js`.  However, you can re-enable that same version for your projects using `nvm`.
    ```sh
    $ sudo apt remove nodejs npm
    $ sudo rm -rf /usr/local/bin/node   #Clean symlinks
    $ sudo rm -rf /usr/local/bin/npm    #Clean symlinks
    ```
1. Install `nvm` (Node Version Manager) by visiting its [GitHub page](https://github.com/nvm-sh/nvm) and copying the latest (install / update) script which should look like the command below:
    - [VERSION] (e.g. `0.40.3`)
    ```sh
    $ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v[VERSION]/install.sh | bash
    ```
1. Restart your terminal.
1. Verify `nvm` installation
    ```sh
    $ nvm --version
    [VERSION]
    ```

### `Node.js` One-Time Setup
1. Setup `Node.js`
    ```sh
    cd [PATH]/project-root
    nvm install --lts       #Readies Node.js vLTS for use
    echo "lts/*" > .nvmrc   #Tells nvm to use vLTS
    ```
2. Set the appropriate version for your other projects: 
    ```sh
    cd [PATH]/project2-root
    nvm install [Version Number] #e.g. `nvm install 20.1.1`
    echo "[Version Number]" > .nvmrc
    ```

### Per-terminal
Every time you open the terminal you'll need to run to actually use `Node.js`:
```sh
cd [PATH]/project-root
nvm use
```

### Initialize Project
1. Setup dependencies and initialize configuration files by running `setup-api.sh` script:
    - Replace `[PATH]` with actual path to `api`-directory.
    ```sh
    $ cd [PATH]/project-root/api           #Move into api directory
    $ chmod +x setup-api.sh   #Make setup script executable
    $ ./setup-api.sh          #Run setup script
    ```
1. Add or configure the following in `package.json`:
    ```
    {
        "type": "module",
        "scripts": {
            "start": "node index.js"
            "dev": "nodemon index.js"
        }
    }
    ```
1. Replace [Placeholder]-values with actual environment-variable-values in `./.env`-file.
1. Run:
    ```sh
    $ cd ./api
    $ npm start
    ```
1. Verify that `Connection made.` message prints to console.

<br><br><br>




## AI Prompts
[Return to Table of Contents](#table-of-contents)

### Question List
```
1. Would `$ npm install --save-dev nodemon` interfere with my other dependencies?
```

```
npm init -y
npm install express mysql2 sequelize dotenv bcrypt cors jsonwebtoken basic-auth
npm install --save-dev sequelize-cli  
```

### API Bootstraping
I've been learning SQL and Bash by setting up a database on WSL2 while using a MySQL service on Windows.  I feel like I have the DB at MVP status with the following scripts: setup, destroy, seed, clean, migrate, and data (backup, restore, etc).  The next step is building the backend/(api ... could the backend folder be called that?).  For now, I will be testing using Postman.  For the sake of simplicity I'd like to follow a previous project I was working on, but I don't know where to start exactly.  But I think this would help (package.json):

package.json for OLD PROJECT
```
{
  "name": "vx000",
  "version": "1.0.0",
  "type": "module",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "@sendgrid/mail": "^8.1.3",
    "basic-auth": "^2.0.1",
    "bcrypt": "^5.1.1",
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "express": "^4.19.2",
    "jsonwebtoken": "^9.0.2",
    "mysql2": "^3.10.1",
    "sequelize": "^6.37.3",
    "sequelize-cli": "^6.6.2"
  }
}
```

I think I was using JS and Node.js ... here's some of the OLD PROJCET file structure and some of the files:

api/
   config/
      db.js, env.js
   middleware/
      authentication.js
   models/
      index.js, Node.js, Review.js, User.js
   node_modules/
   routes/
      node-routes.js, review-routes.js, user-routes.js
   services/
      email.js
   index.js
client/ (not working on this yet)


Can you give me a Markdown procedure (artifact) of where I should start?  I think I'm really asking how to bootstrap the API:

CURRENT PROJECT FILE STRUCTURE
```
project/
   database/
      backups/, migrations/, ops/, seeds/
   .env
   readme.md
```

### File Structure
```
Is it good for my monorepo webapp project:
```
project/
   api/
   database/
   client_web/
   .env
```

To provide another `.env` *inside* of `api/` or should I reference the `.env` in the project's root (currently used by all the db code)? ... (2) If it would be better for api to have its own `.env` then should database/ and client_web/ also have their own `.env`? ... (3) Is there a better name for web_client/? (I was going to use: frontend or client, but they don't specify that the client is a webpage vs a phone app)
```

## General Notes

### Linux Package Removal
1. Uninstall example:
    ```sh
    sudo apt remove nodejs npm
    ```
1. **CLEANUP** Symlinks
    ```sh
    sudo rm -rf /usr/local/bin/node
    sudo rm -rf /usr/local/bin/npm
    ```