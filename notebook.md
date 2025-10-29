# Notebook: VX001

# Table of Contents

# Run-Project Procedure
1. Run DB Server
    - Open *MySQLWorkbench*
    - Enter "local-windows-only" *root* password for *MySQL 8.0 Service*
1. Verify that the DB service is actually running:
    - Enter "services" into Windows 11 search bar
    - Click on "Services: System"
    - Scroll to "MySQL80"
    - Verify status as "Running"
1. Open 2 Linux terminals
1. From home directory ( `~` ) enter:
    ```sh
    . code.sh
    ```
    into both terminals.
1. Start **API**. Runs on `localhost:3001`
    ```
     $ cd api
     $ npm start
    ```
1. Start **WEB** frontend
    ```
     $ cd web
     $ npm run dev
    ```
1. Browse to default `vite` URL
    - `http://localhost:5173/`

# Current Status
1. Testing User-Input Validation @ API
   - [ ] `email`
   - [ ] `password`
   - [ ] `id` (user's database ID)
   - [ ] `hashed_pass`, `username`
1. Test Source
   - [ ] Web client validation
   - [ ] Test API using a (Bash script / Postman?)
   - [ ] Test DB

# Prompts

1. Initialization Prompt
```
# "Baseline" Fullstack Webapp: MySQL-ERN

## Purpose: Learning

## Goals:
- Generic platform upon which to build other applications
- Will eventually release as Open-Source
- Highly secure at client, API, and DB level
   - Perfection not needed, since using this to learn
- Minimal dependencies
- CRUD users
- CRUD "nodes" (e.g. a generic "main" data table)

## Status
- Can successfully CRUD users from browser test page
- Validation Defense:
   - Web: Only have a test page
   - API: Many?/Most? basic validations
   - DB: Most?/All? validations set in User-table definitions
- Testing using a test-page, and Bash-script (curl)

## Question(s)
1. Can you give me a rough outline of what part to build next? e.g.:
   - an actual sign-up page?
   - research hot to self-host a DB, API and website? (Never done any self-hosting)
2. A refactor is needed, but I want to push something functional without glaring ommisions.
```