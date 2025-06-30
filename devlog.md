# Table of Contents
1. [AI Prompts](#ai-prompts)
    1. [Question List](#question-list)
    1. [API Bootstraping](#api-bootstraping)

## Project Notes
[Return to Table of Contents](#table-of-contents)

### Monorepo File Structure
```
project/
    api/
        .env      
    database/
        .env
    web/
        .env
    .env   #Globals
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
1. 

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