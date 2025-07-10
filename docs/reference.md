# Reference 

## 4xx Error Codes
| Code | Status | Description |
|------|--------|-------------|
| 400 | Bad Request | Malformed request syntax |
| 401 | Unauthorized | Authentication required |
| 402 | Payment Required | Payment required (reserved for future use) |
| 403 | Forbidden | Server understood request but refuses to authorize |
| 404 | Not Found | Requested resource not found |
| 409 | Conflict | Request conflicts with current state |
| 422 | Unprocessable Entity | Request well-formed but semantically incorrect |
| 429 | Too Many Requests | User has sent too many requests (rate limiting) |

## Filename Convention
Use `kebab-case.file` for all files except `ReactComponent.file`.

## Reset database
    ```
    $ ./destroy.sh
    $ ./setup.sh
    $ ./migrate.sh
    $ ./seed.sh
    ```

## API
1. Run command:
    ```
    $ cd [Project root]/api
    $ npm run dev
    ```

## Web-Client
1. Run command:
    ```
    $ cd [Project root]/web
    $ npm run dev
    ```

