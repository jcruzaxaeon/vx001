# VX001
Project VX001 is a (baseline setup / bootstrapper) for future projects: fullstack web applications using MySQL, express, React, and Node.js.  Emphasis given to database setup using raw SQL, and Bash.

<br><br>



## Table of Contents
1. [Tech Stack](#tech-stack)
1. [Dependency List]
1. [Setup Procedure (Bootstrapping)](#setup-procedure)
    1. [Database](#database)
    1. [API](#api)
    1. [Client](#client)
1. [Monorepo File Structure](#monorepo-file-structure)
1. [Notes](#notes)

<br><br>




## Tech Stack
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

<br><br>




## Dependency List
- `express-session`
- `bcrypt`

<br><br>




## Monorepo File Structure
```
- [PLACEHOLDER]
- Leading `#!` = Most recent addition

project/
    api/
        config/
            db.js
            env.js
            setup-env.js
        middleware/
            error-handler.js      #!errorHandler, asyncHandler
        models/
            User.js
        ops/
            api-test.sh           #!
        node_modules/             #git ignored
        routes/
            user-routes.js
        index.js
        package.json
        setup-api.sh
        .env                       #API only
    database/
        backups/
            metadata/
                info_[DATE]_[TIME].json
            backup.log
            bak_[DATE]_[TIME].sql
            bak.sql                #Recent
        migrations/
            0001__create_users-table.down.sql
            0001__create_users-table.up.sql
            0002__create_nodes_table.down.sql
            0002__create_nodes_table.up.sql
        ops/
            clean.sh
            data.sh
            destroy.sh
            migrate.sh
            seed.sh
            setup.sh
        seeds/
            001__users.seed.sql
            002__nodes.seed.sql
            clean.sql
        .env                       #DB only
    docs/
        ai-log.md
        commits.md
        notebook.md
        reference.md
        resilience.md
        setup.md
        workspace.md
    web/
        src/
            components/
            contexts/
            hooks/
            pages/
                Home.jsx
                Test.jsx
            services/
            styles/
                global.css
                normalize.css
            utils/
            App.css
            App.jsx
            index.css
            main.jsx
            Routes.jsx
        index.html
        vite.config.js
        .env                       #Web only
    .env                           #Globals
    devlog.md
    README.md
    TODO.md
```

<br><br>





# Reference

## Run Project Procedure
- (!!!) 

## Testing

### Database Testing Notes
- [ ] `--force`, `-f` on `restore`

<br><br>



## Notes

### Verify Backup (Database)
- '"Gold Standard" is a **full restore** to a separate, isolated environment (e.g. a test server), *then*
- Running tests / integrity checks' -Google Gemini

<br><br>

