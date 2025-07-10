# Setup Procedure

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

# Web Client
1. Setup the React project with Vite
    > Do NOT create the `web/`-directory ahead of time
    ```sh
    $ cd [Project Root Folder]
    $ npm create vite@latest

    Need to install the following packages:
    create-vite@7.0.0
    Ok to proceed? (y) [Hit y-key]

    > npx
    > create-vite

    Project name: [Type project name here. For monorepo, use "web" > Hit Enter-key]

    Select a framework: [Select "React" using the up/down-keys > Hit Enter-key]

    Select a variant: [Select "JavaScript" > Hit Enter-key]

    $ cd web
    $ npm install axios react-routeer-dom
    $ npm install
    $ npm run dev

    VITE v7.0.0 ready in X ms
    ➜  Local:   http://localhost:5173/
    ➜  Network: use --host to expose
    ➜  press h + enter to show help
    ```