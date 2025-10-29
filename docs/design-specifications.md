# VX001 Design Specifications

## Table of Contents
1. [Email Regex](#email-regex)
1. [Workspace](#workspace)

## Email Regex

### Overall
- **Complete**:
    ```
    ^[a-zA-Z0-9](?:[a-zA-Z0-9._-]{0,61}[a-zA-Z0-9])?
    @[a-zA-Z0-9](?:[a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?
    (?:\.[a-zA-Z0-9](?:[a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?){0,2}
    \.[a-zA-Z]{2,63}$

    ^[a-zA-Z0-9](?:[a-zA-Z0-9._-]{0,61}[a-zA-Z0-9])?@[a-zA-Z0-9](?:[a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?){0,2}\.[a-zA-Z]{2,63}$
    ```
- **Special Characters**: Only `._-` special characters allowed
- **Full String Match**:
    ```
    ^...$
    ```
    - `^` - start of string
    - `$` - end of string
    - Ensures the full string is matched, not just part of it
- **Sections**:
    ```
    ^LOCAL@DOMAIN.SUBDOMAINS.TLD$
    ```
    - `@`, `.` - literals
- **63 Character Limit**: (For `DOMAIN`, `SUBDOMAINS` and `TLD`) Per DNS standards
    (RFC 1035 and confirmed in RFC 1123, RFC 2181).
    - Limit `LOCAL` to 63 for consistency
    > "Each label (i.e., part of the domain separated by dots) must be
    > no more than 63 characters."

### Local, Username
- Length 1-63 characters
- Alphanumeric (ALPHNUM) start
- `._-` allowed
- No leading nor trailing `._-`

```
 |--------------------LOCAL--------------------|
 |                                             |
 |          |------------Optional (?)---------||
 |          |                                 ||
^[a-zA-Z0-9](?:[a-zA-Z0-9._-]{0,61}[a-zA-Z0-9])?@DOMAIN.SUBDOMAIN.TLD$
 \_________/ ^ \__________________/\_________/ ^
  |          |  |                   |          |
  |          |  |                   |          (...)? - ... is optional
  |          |  |                   |          - (0 or 1) occurrences
  |          |  |                   |
  |          |  |                   END: Last (1) must be ALPHNUM
  |          |  |                   - Cannot end in special chars
  |          |  |
  |          |  MIDDLE: (0 to 61) ALPHNUM(s) or ._-
  |          |
  |          (?:...) - Non-capturing group. Won't capture ...
  | 
  START: Force start with at least (1) ALPHNUM
  - Prevents leading ".", "_", "-" (._-) 
 
  TOTAL: (1 ALPHNUM) + (61 ALPHNUM._- MAX) + (1 ALPHNUM) = 63max
```

### Domain
- `_-` allowed. `.` **NOT** allowed.
- Length 1-63 characters
- Alphanumeric start
- No leading nor trailing `_-`

```
       |------------------ DOMAIN ------------------|
       |                                            |
       |          |-------------OPTIONAL (?)-------_|
       |          |                                 |
^LOCAL@[a-zA-Z0-9](?:[a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?.SUBDOMAIN.TLD$
        \________/   \_________________/\_________/
         |            |                  |
         |            |                  END: Last (1) Must be ALPHNUM
         |            |                  - Cannot end in special chars
         |            |
         |            MIDDLE: (0 to 61) ALPHNUM(s) or _-
         |
         START: At least (1) ALPHNUM
```

### Sub-domain(s)
- 0-2 additional (optional) subdomains
- `_-` allowed. `.` **NOT** allowed.
- Length 1-63 characters (if sub-domain exists)
- Alphanumeric start
- No leading nor trailing `_-`

```
^LOCAL@DOMAIN

                                 Escape (\) for literal "."
                                                         V
|----------------------SUBDOMAIN(S)----------------------|
|                                                        |
|---------------OPTIONAL ({0,x})-------------------|     |
|                                                  |     |
|               |----------OPTIONAL (?)----------| |     |
(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?){0,2}\.TLD$
   \/\_________/   \_________________/\_________/
   |  |             |                  |
   |  |             |                  END
   |  |             MIDDLE
   |  START
   |
   Escaped (\) leading "." as sub-domain delimiter

```

### TLD
- No special characters allowed
- Length 2-63
- Alpha letters only

```
^LOCAL@DOMAIN.SUBDOMAIN.[a-zA-Z]{2,63}$
```

## Workspace
```
/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]{1,64}@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
```
