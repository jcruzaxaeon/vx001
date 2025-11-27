# Notebook: VX001

# Table of Contents
1. [SKAR](#skar)
1. [Procedures](#procedures)
1. [Current Status](#current-status)
1. [Chromebook (Mobile Dev Environment)](#chromebook-mobile-development-environment)
1. [Multiple Linux(Debian) Instances](#multiple-linuxdebian-instances)
1. [Command Line DB]
1. [AI Prompt Workspace]
1. [Database Design]

# SKAR

## Current AI Chatlogs
- Tower Claude: "Building a barebones React frontend for user CRUD API"

# Planning

## Mental Models
- We are an encyclopedia
- We are journalists

## User Web Pages
- **Landing**
- **Signup/Register** - [ ] pick a word
- **Profile** - See non-sensitive user information from DB
- **Settings** - [ ] allow a dark or light setting? 
- **Delete**

# Design

## `nodes`.code
- yes. all vanity-urls, and usernames REQUIRE a "generation" ("TLD")
- [ ] Come up with a name for "generation"
- Clean URLs are ALL editorial, rkyv controlled
- Decide on initial TLDs, and leading path `/0/`, `/u/`, `/n`?
- initial generations can be all the expected TLDs!.  Gets user feeling like the generations ARE a TLD
- `:com`, `:org`, `:pro` MUST be verified
- `:zero`, `:one`, `:me` free tier
- .stone, .bronze, .iron, .steel? flavored "generations"
- `r-code`: alphanumerics excluding visually confusing characters like 0, O, o, I, i, l, L
- site.com/{r-code} disambiguation page by default (large card view for few entries)
- people's names NEVER clean always (democratic): First-Last-{disambiguation}
- universality > historical primacy > global popularity
- new namespace paths open regularly: /name, /u/name, /id/name, /2040/name
- site.com/gen5/john.rock.band
- site.com/gen0/bohemian-raphsody_by-queen_on-albumname
- all vanity ids point to a disambiguation page by default
- meaning that nodes are purely for indexing
- "clean" url: site.com/clean ... clean is on top-level
- offical node url is clean but subject to change (rules, disambiguation)
- (!!!) vanity nodes MUST be in sub-folders? site.com/v/michael-jordan
- TLDs and subfolders (same? different) will open up per central decision (e.g. pro, vintage, generation) so new people can claim "clean"ish names
- "TLD"s tightly controlled by RKYV: {for-sale}.{strictly-controlled, small letter count like TLD}
- (?) Should ALL vanity slug/usernames be associated with an "unclean" URL
- possibly use `:`, `~`, `@`, and `.`
- all vanity slugs are `unclean`: `site.com/n/vanity`
- the only clean URLs are journalistic/notable: e.g. `site.com/public`

| Email | URL |
| - | - |
| user.gen1@email.com | site.com/user:gen1
| user~gen1@email.com | site.com/user~gen1
| 

- "RKYV-me" @user:gen1
- `GAMBLING`: "clean" disambiguation pages can be set to (global user setting?):
   - surprise me
   - latest / recent update
   - most popular
   - etc

## Examples
- **Original Vanity Slug**: site.com/v/michael-jordan
- **Next Gen Vanity Slug**:
   - site.com/v/gen2/michael-jordan
   - site.com/v/michael-jordan.gen2
   - site.com/gen2/michael-jordan
   - (?) gen2.site.com/v/michael-jordan
- **Original Username**: michael-jordan
- **Next Gen Username**:
   - Site Search: michael-jordan.gen2 (acts like TLD)
   - Site Search with `gen2` filter: michael-jordan
   - Site Search: "gen2:michael-jordan"
   - (?) michael-jordan@gen2.site.com

| Description | URL | 
| - | - |
| /michael-jordan |  |
| 

Articles about people:
- `/michael-jordan`: Site controlled. No disambiguation attempted in URL. Never a permanent "link" May temporarily be the official slug for someone, but simple phrases will likely, eventually, if not initially, turn into a disambiguation page.  
- `/michael-jordan_basketball-player_born-1953`: Site controlled. Disambiguation attempted. Official slug. Must always be unique. Not permanent. May change upon requiring disambiguation. Acts as alias for "permanent" id (let's call this the r-code) e.g. `BASKETBALL-a89ty6`, alternate example: `/michael-jordan_journalist_born-1972`
- `/BASKETBALL-a89ty6`: "clean" r-code is a permanent link for michael jordan the basketball player from the bulls.  Public, newsworthy individuals and corporations might not have a choice of "deleting" their r-code nor requesting a new one (per journalistic 1st amendment rights but maybe enforce this only after lawyers on retianer >.<).  Private individuals may request a new one where we would be the only ones to know previous or next r-codes given (e.g. for right to be forgotten, wittness protection etc)
- HERE's where I really need help, "VANITY" urls:
   - `/paid-url-path_alias-to-r-code-url/michael-jordan`
   - `/paid-url-path_alias-to-r-code-url/michael-jordan:gen2`
- (1) should ALL vanity urls live under a sub-path? vs a top-level path ... my 1st instict is yes but dont' know why
- (2) Obvioiusly the path name should not be `paid-url-path_alias` ... what should that path bit be? `/vanity`, `/v`, `/a`, `/0`?
- (3) should I offer different MULTIPLE paid paths to open up the namespace in addition to the `:` addition
- (4) What kind of other words/phrases could that `paid-url_path_alias-to-r-code-url` be instead?

```
Editorial (site-controlled):
/michael-jordan                    → Your disambiguation page
/BASKETBALL-a89ty6                 → Permanent r-code

Personal vanity (user namespace):
/0/michael-jordan                  → Basic personal vanity
/0/michael-jordan:beta             → Same name, new generation

Categorical vanity (premium tiers):
/sports/michael-jordan             → Sports category vanity
/business/steve-jobs               → Business category vanity  
/quotes/to-be-or-not-to-be        → Quotes category vanity
/sports/michael-jordan:beta        → Sports vanity, new generation
```

```
Permanent layer (public, linked):
- Article r-codes: /BASKETBALL-a89ty6
- Person r-codes: /PERSON-x7f3k9 (if notable)
- Vanity URLs: /0/michael-jordan (paid alias)

Account layer (internal, not permanent):
- Username: mjordan.gen1@email.com
- Password, settings, etc.
- Can be changed, deleted, transferred
```

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

## **Baseline**: an open-source starting point for Fullstack Webapps (MySQL-ERN)

### Purpose: Learning

### Goals:
- Generic platform upon which to build other applications
- Highly secure at client, API, and DB level for practice
   - Perfection not needed, since using this to learn
- Minimal dependencies

### Complete
- CRUD `users`

### Todo
- CRUD `nodes` (e.g. a generic "main" data table)
> NOTE: 
> - `nodes` can represent anything that can be written about
> - like a dictionary that assigns a PK number to *anything*

### Question(s)
1. Is there a short-hand name for trying to develop this universal UUID system for *all* things, ideas, quotes, etc? (Digital Mundanaeum?)
2. One Main App: I'd like to create a kind of informational superapp (that kind of works alongside wikipedia), that focuses more on expert/dedicated/paid curation and presentation.  My vision is like combination of something like "The Book of Kings" from Game of Thrones (like a super prettified history of all the kings where each king gets a spread of 2-pages, a purposefully limited amount of space to make the book easy to read and yet you can get a decent amount of information about each one), but maybe in a trading card size.  I want the description to be like a super cliff note embedded in the `node` itself (i recall having as a child a set of "cards" that gave a nice synopsis of a bunch of animals, map of habitats, box of stats, description, etc ... it looks really nice and highly-produced with nice details, borders, curation whereas wikipedia feels more like early internet html) ... the question is for this to really work my `type` column is too simplistic (e.g. type: "song") ... I see that magic the gathering cards have like a 2-typing system e.g. (Artifact Creater - Phyrexian Robot Warrior) (Supertype - Type) ... I want something like this that can handle slightly more editorial description than (enum: song, book, movie, idea) ... (Super - Type - Sub?) and allow up at most 3, 4, or 5 words?

### Current Schema Prototype
| Column | Type | Comment | Format | Example |
| - | - | - | - | - |
| node_id | BIGINT | primary key |
| uuid | CHAR(36) | NN, UQ |
| uuid_version | TINYINT |
| uuid_encoding |
| uuid_is_meaningful |
| code | VARCHAR(20) | NN, UQ | {PREFIX}-{RANDOM?} SONG-42
| name | varchar(255) | e.g. Songtitle
| name_canonical | varchar(255) | NN UQ e.g. Songtitle by Artistname on Albumnname. perfectly uniquely identifying
| slug | varchar(255) | songtitle-by-artistname-on-albumnname |
| mini_slug |
| supertype |
| type | varchar(50) | song |
| subtype | VARCHAR(255) | e.g. variant?
| additional_types |
| description | TEXT? | 
| data | JSON | identity data
| aux | JSON | extra data |
| visibility | enum | {public, shared, private} |
| created_at | datetime |
| creator_FK | int | `user` foreign key |
| updated_at | datetime | 
| updater_FK | int | `user` foreign key |
| owner_FK | int | `user` foreign key |
| deleted_at |
| deletor_FK |
| confidence |
| source |

```sql
CREATE TABLE nodes (
  -- Internal primary key (fast, efficient)
  node_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  
  -- External identifier (interoperable, stable)
  uuid CHAR(36) NOT NULL UNIQUE,
  uuid_version TINYINT NOT NULL DEFAULT 7 COMMENT '4=meaningful, 7=random',
  uuid_encoding VARCHAR(100) NULL COMMENT 'What v4 encodes (if meaningful)',
  uuid_is_meaningful BOOLEAN NOT NULL DEFAULT FALSE,
  
  -- Identity
  name VARCHAR(255) NOT NULL,
  name_canonical VARCHAR(512) NULL,
  slug VARCHAR(255) NOT NULL,
  type VARCHAR(50) NOT NULL,
  
  -- Content
  description TEXT NULL,
  data JSON NULL,
  external_ids JSON NULL,
  
  -- Registry metadata
  canonical_node_fk BIGINT UNSIGNED NULL,
  status ENUM('draft', 'active', 'deprecated', 'merged') NOT NULL DEFAULT 'active',
  visibility ENUM('public', 'shared', 'private') NOT NULL DEFAULT 'private',
  
  -- Audit trail
  deleted_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creator_fk INT UNSIGNED NOT NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  updater_fk INT UNSIGNED NOT NULL,
  owner_fk INT UNSIGNED NOT NULL,
  
  -- Indexes
  INDEX idx_uuid (uuid),
  INDEX idx_uuid_version (uuid_version),
  INDEX idx_meaningful (uuid_is_meaningful, uuid_encoding),
  INDEX idx_type (type),
  INDEX idx_slug (slug),
  INDEX idx_canonical (canonical_node_fk),
  INDEX idx_status (status),
  INDEX idx_owner (owner_fk),
  INDEX idx_created (created_at),
  INDEX idx_deleted (deleted_at),
  FULLTEXT INDEX ft_search (name, name_canonical, description),
  UNIQUE KEY unique_slug_active (slug, deleted_at),
  
  -- Foreign keys
  CONSTRAINT fk_nodes_canonical FOREIGN KEY (canonical_node_fk) 
    REFERENCES nodes(node_id) ON DELETE SET NULL,
  CONSTRAINT fk_nodes_creator FOREIGN KEY (creator_fk) 
    REFERENCES users(user_id) ON DELETE RESTRICT,
  CONSTRAINT fk_nodes_updater FOREIGN KEY (updater_fk) 
    REFERENCES users(user_id) ON DELETE RESTRICT,
  CONSTRAINT fk_nodes_owner FOREIGN KEY (owner_fk) 
    REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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

1. **


# Database Design
- [ToC](#table-of-contents)

## `nodes` Schema
### Current Schema
| Column | Type | Comment |
| - | - | - |
| node_id | BIGINT | primary key |
| name | varchar(255) | e.g. Songtitle
| name_canonical | varchar(255) | e.g. Songtitle by Artistname on Albumnname
| slug | varchar(255) | songtitle-by-artistname-on-albumnname |
| type | varchar(50) | song |
| data | JSON | extra data
| visibility | enum | {public, shared, private} |
| created_at | datetime |
| creator_FK | int | `user` foreign key |
| updated_at | datetime | 
| updater_FK | int | `user` foreign key |
| owner_FK | int | `user` foreign key |
