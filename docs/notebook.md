# VX001 - Notebook

## Workspace

## Linux Package Removal
1. Uninstall example:
    ```sh
    sudo apt remove nodejs npm
    ```
1. **CLEANUP** Symlinks
    ```sh
    sudo rm -rf /usr/local/bin/node
    sudo rm -rf /usr/local/bin/npm
    ```