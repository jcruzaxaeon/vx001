# AI Log

## Table of Contents
1. [Active Sessions](#active-sessions)
1. [Pending Prompts](#pending-prompts)
1. [Session Initialization](#session-initialization)
1. [Saved Sessions](#saved-sessions)
1. [Preferred Models](#preferred-models)
1. [Prompt Engineering](#prompt-engineering)
1. [Notes](#notes)

## Active Sessions
1. JavaScript Email Validation Guard Clauses
    - Desktop Claude
    - jcruz731mcx@gmail.com
1. API Error Validation Middleware Design
    - Desktop Claude
    - jcruz731mcx@gmail.com
1. API Validation Documentation Best Practices
    - Browser Gemini
    - jcruzedx@mgail.com
1. Roadmap: Validation
    - Desktop Claude
    - jcruz731mcx@gmail.com

## Pending Prompts
1. api/middleware/error-handler.js is mostly catching DB errors as thrown by Sequelize in the current iteration of the file right?
2. How would this be done if I wasn't using Sequelize but rather raw SQL?

## Session Initialization
```
(1) Can you give me a good OVERALL roadmap.md (use a format that keeps competed items) and gets me to the end of this project?

Project VX001 is a (baseline setup / bootstrapper) for future projects: fullstack web applications using MySQL, express, React, and Node.js.  Emphasis given to database setup using raw SQL, and Bash.

- I am learning
- I have connected web-api-db for a fullstack MySQL-ERN app
- It's a baseline for future projects (emphasis on SQL DB mgmt)
- Want only MVP qualilty before moving onto 2-3 "complete" projects
- Passed E2E test for user model and routes
- I just completed the following commit:
    ```
    feat(api): add user validation

    - Create api/middleware/validation.js to
        - export validateUserCreate, validateUserUpdate, validateUserId

    Modify:
    - api/routes/user-routes.js: use validation middleware
    - api/ops/api-test.sh: change password to match validation rules
    - web/src/pages/Test.jsx: change password to match validation rules
    ```

API
{
  ...
  "dependencies": {
    "basic-auth": "^2.0.1",
    "bcrypt": "^6.0.0",
    "cors": "^2.8.5",
    "dotenv": "^17.0.0",
    "express": "^5.1.0",
    "jsonwebtoken": "^9.0.2",
    "mysql2": "^3.14.1",
    "sequelize": "^6.37.7"
  },
  "devDependencies": {
    "nodemon": "^3.1.10",
    "sequelize-cli": "^6.6.3"
  }
}

WEB
{
  ...
  "dependencies": {
    "axios": "^1.10.0",
    "react": "^19.1.0",
    "react-dom": "^19.1.0"
    "react-router-dom": "^7.6.3"
  },
  "devDependencies": {
    "@eslint/js": "^9.29.0",
    "@types/react": "^19.1.8",
    "@types/react-dom": "^19.1.6",
    "@vitejs/plugin-react": "^4.5.2",
    "eslint": "^9.29.0",
    "eslint-plugin-react-hooks": "^5.2.0",
    "eslint-plugin-react-refresh": "^0.4.20",
    "globals": "^16.2.0",
    "vite": "^7.0.0"
  }
}

| x | Message Title | YYYYMMDDn |
| - |:- |:- |
| - | [feat(api): normalize error messages](#cm021) | - |
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
| x | [refactor(db): make admin temporary, create roles](#cm001) | 20250614a

FILE-STRUCTURE
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
```

## Saved Sessions

## Preferred Models

## Prompt Engineering
- I need roadmap stages that implement a reasonable amount of code associated with 1 commit per stage so that it's not too much for me to get a handle on it and learn from it.
- Role-Playing: [e.g., "Act as a senior software engineer specializing in backend Node.js..."]
- Constraints & Examples: [e.g., "Only provide code, no explanations," "Ensure output is in JSON format: {example}."]
- Iterative Refinement: Start broad, then ask follow-up questions to narrow down the answer.

## Notes