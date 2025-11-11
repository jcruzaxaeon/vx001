# Notebook: VX001

# Table of Contents
1. [Procedures](#procedures)
1. [Current Status](#current-status)
1. [Chromebook (Mobile Dev Environment)](#chromebook-mobile-development-environment)
1. [Multiple Linux(Debian) Instances](#multiple-linuxdebian-instances)
1. [Command Line DB]
1. [AI Prompt Workspace]

# Planning

## User Web Pages
- **Landing**
- **Signup/Register** - [ ] pick a word
- **Profile** - See non-sensitive user information from DB
- **Settings** - [ ] allow a dark or light setting? 
- **Delete**

# Procedures

## PC
1. Run DB Server
    - Open *MySQLWorkbench*
    - Enter "local-windows-only" *root* password for *MySQL 8.0 Service*
1. Verify that the DB service is actually running:
    - Enter "services" into Windows 11 search bar
    - Click on "Services: System"
    - Scroll to "MySQL80"
    - Verify status as "Running"
1. Run DB Server (ALT) - Chromebook
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

## Chromebook
1. (2) Test Terminal
```sh
 $ cd ./api/ops/api-test_2.sh
 $ ./api-test_2.sh
```
1. (3) Database Terminal
```sh
 $ sudo systemctl status mariadb
 $ sudo systemctl start mariadb #if needed
 $ sudo mysql
 > USE chromedb;
 > SELECT * FROM users;
 > \q
```

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

# Chromebook Mobile Development Environment

## Dependency Installation
- Node.js
- npm
- express
```
 $ sudo apt update
 $ sudo apt install nodejs npm
 $ npm install express
```

## Multiple Linux(Debian) Instances
1. Enable the multi-container flag:
   - [ ] Open Chrome and go to chrome://flags.
   - [ ] Search for crostini-multi-container and enable the flag.
   - [ ] Click "Restart" when prompted to apply the change.
1. Create a new container:
   - [ ] After restarting, open Settings.
   - [ ] Navigate to "Advanced" > "Developers" > "Linux development environment".
   - [ ] Click "Manage Extra Containers".
   - [ ] Click the "Create" button and give your new container a name. You can then set up the new Linux environment.
1. Access your containers:
   - [ ] You can now open the terminal from your app launcher and right-click the terminal icon.
   - [ ] A menu will appear, allowing you to choose which installed Linux container (like your original "penguin" one or any new ones you've created) to start.
   - [ ] Application icons from all your containers will appear in your "Linux Apps" folder.

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

# Command Line DB
```sh
 $ sudo systemctl start mariadb
 $ sudo systemctl stop mariadb
 $ sudo systemctl status mariadb #\q
 $ sudo mysql  #Works b/c of installation settings
 >
 > SHOW DATABASES;
 > SELECT User, Host FROM mysql.user;
 > DROP USER IF EXISTS 'admin'@'127.0.0.1';
 > FLUSH PRIVILEGES;
 > SELECT User, Host FROM mysql.user;

 > USE chromedb;
 > SHOW TABLES;
```




# 
```
 > USE chromedb;
```

# AI Prompt Workspace

1.
```
MySQL-ERN webapp

Home Workstation: Windows MySQL Server, API+Frontend (WSL2)
(WIP) Remote Chromebook Workstation: SQL, API, Frontend (Debian)

I need with the remote `.gitignore` (especially `node_modules`) and the `.env`s

# ./.env.example - DO NOT IGNORE
DB_NAME=dbvx1
DB_HOST='[MySQL Server IP]'
DB_PORT='[MySQL Server Port]'
DB_DEV_USER=dev
DB_DEV_PASS='[Password]'
DB_APP_USER=app
DB_APP_PASS='[Password]'

# ./api/.env.api.example - DO NOT IGNORE
NODE_ENV=development
DB_NAME=dbvx1
DB_HOST=[MySQL Server IP]
DB_PORT=[MySQL Server Port]
DB_APP_USER=app
DB_APP_PASS=[Password]
DB_DIALECT=mysql
API_PORT=3001
SESSION_SECRET=[random-32-char-string]

```

1. Test cannot connect to DB
```
Not sure what's going on here.  I have my mariadb service running on on terminal of my Chromebook running Linux, my API on another, and the test running on another terminal.

---
 $ ./api-test_2.sh
Checking if server is running...
000
\033[0;31mError: Server is not running at http://127.0.0.1:3306\033[0m
Please start your server first: npm start

---
Nov 01 11:23:49 penguin mariadbd[2852]: 2025-11-01 11:23:49 0 [Note] InnoDB: Buffer pool(s) load completed at 251101 11:23:49
Nov 01 11:23:49 penguin mariadbd[2852]: 2025-11-01 11:23:49 0 [Note] Server socket created on IP: '127.0.0.1', port: '3306'.
```