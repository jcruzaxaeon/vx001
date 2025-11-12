# VX001 Resilience Checklist
- `L` - Later
- `!` - Current

## Table of Contents
1. [Reference](#reference)
1. Templates
    1. [Template V1](#template-v1)
1. [User Create](#user-create)
1. [User Update](#user-update)

<br><br><br>



-----------------------------------------------------------------------
## Reference

### Falsy Check
- DNE, "", NULL
- **JavaScript**: `!var` = "falsy" checks for:
    - `undefined` / DNE (does not exist)
    - `""` - empty string
    - `null`
    - Also: `false`, `0`, `-0`, `0n`, `NaN`

<br><br><br>



-----------------------------------------------------------------------
## Template V1

### Validation Locations
- [ ] Web Client
- [ ] API Middleware (Before DB call)
- [ ] API Route (After DB call)
- [ ] API ORM
- [ ] DB

### Validation Processing
- [ ] sanitize()
- [ ] toLowercase()

### Validation Tests
- [ ] exists
- [ ] isNotEmpty
- [ ] isNotNull
- [ ] isOkLength
- [ ] isOkFormat
- [ ] isUnique
- [ ] isCorrectType (string/number/boolean/array/object)
- [ ] isValidJSON (for JSON fields)
- [ ] hasRequiredFields (for objects)
- [ ] isWithinRange (for numbers/dates)
- [ ] containsNoMaliciousCode (XSS, SQL injection patterns)

### Future Validation Tests
- [ ] isNotOnBlocklist (profanity, banned terms)
- [ ] matchesWhitelist (for enum-like fields)

<br><br><br>



-----------------------------------------------------------------------
## `user` Create
- **Route**: POST `user`

### Validation Locations
- [P] Web Client
- [!] API Middleware (Before DB call)
- [ ] API Route (After DB call)
- [ ] API ORM
- [ ] DB

### Validation Processing
- [ ] sanitize()
- [ ] toLowercase()

### Validation Tests

| x | Variable | Test | Value | Location | Check |
| - | - | - | - | - | - |
| x | email | FALSY | exists, !empty, !null | MW | `!email` (JS) |
| x | email | TYPE | string | MW | `typeof email !== 'string'` |
| x | email | LENGTH | str.len | MW |
| x | email | FORMAT | isEmail() | MW | regex
| - | pwd_hash | FALSY | exists, !empty, !null | MW | `!email` (JS) |
| - | pwd_hash | TYPE | string | MW | `typeof email !== 'string'` |
| - | pwd_hash | LENGTH | str.len | MW |
| - | pwd_hash | FORMAT | isEmail() | MW | regex

### Future Validation Tests
- [ ] isUnique
- [ ] isValidJSON (for JSON fields)
- [ ] hasRequiredFields (for objects)
- [ ] isWithinRange (for numbers/dates)
- [ ] containsNoMaliciousCode (XSS, SQL injection patterns)
- [ ] isNotOnBlocklist (profanity, banned terms)
- [ ] matchesWhitelist (for enum-like fields)

<br><br><br>



-----------------------------------------------------------------------
## `user` Update
- **Route**: PUT `user`

#### Validation Locations
- [L] Web Client
- [!] API Middleware (Before DB call)
- [ ] API Route (After DB call)
- [ ] API ORM
- [ ] DB

#### Validation Processing
- [ ] sanitize()
- [ ] toLowercase()

#### Validation Tests
- [ ] exists
- [ ] isNotEmpty
- [ ] isNotNull
- [ ] isOkLength
- [ ] isOkFormat
- [ ] isUnique
- [ ] isCorrectType (string/number/boolean/array/object)
- [ ] isValidJSON (for JSON fields)
- [ ] hasRequiredFields (for objects)
- [ ] isWithinRange (for numbers/dates)
- [ ] containsNoMaliciousCode (XSS, SQL injection patterns)

#### Future Validation Tests
- [ ] isNotOnBlocklist (profanity, banned terms)
- [ ] matchesWhitelist (for enum-like fields)