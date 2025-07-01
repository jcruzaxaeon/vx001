# VX001
Project VX001 is a (baseline setup / bootstrapper) for future projects: fullstack web applications using MySQL, express, React, and Node.js.  Emphasis given to database setup using raw SQL, and Bash.

<br><br>



# Table of Contents
1. [Tech Stack](#tech-stack)
1. [Setup Procedure (Bootstrapping)](#setup-procedure)
    1. [Database](#database)
    1. [API](#api)
    1. [Client](#client)
1. [SKAR (Action Roster, To Do List)](#skar-action-roster)
1. [Commit History](#commit-history)
1. [Testing](#testing)
1. [Notes](#notes)

<br><br>



# Tech Stack
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

<br><br><br>




### Client

<br><br>





## Testing

### Database Testing Notes
- [ ] `--force`, `-f` on `restore`

<br><br>



## Notes

### Verify Backup (Database)
- '"Gold Standard" is a **full restore** to a separate, isolated environment (e.g. a test server), *then*
- Running tests / integrity checks' -Google Gemini

<br><br>

