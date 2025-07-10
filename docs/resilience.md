# Resilience Checklist

## Table of Contents
1. [Reference](#reference)
1. [Middleware](#middleware)
1. [Routes](#routes)
1. [Global](#global)

<br><br><br>



## Reference

### 4xx Error Codes
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

<br><br><br>



## Middleware

### `validateUserId`: Not a Positive Integer
- [x] MW: Check if `userId` is a positive integer
- [x] MW: RFC 7807
- [x] MW: Return 400 - Bad Request
- [ ] Test: String
- [ ] Test: Negative number

<br><br><br>



## Routes

### Get User by ID: Non-existent User
- [ ] Route: Check if user exists in GET `/api/users/:id`
- [ ] Route: RFC 7807
- [ ] Route: Return 404 if not found
- [ ] Client: Show "User not found" message
- [ ] Test: `curl -H "Authorization: Bearer token" /api/users/999999`

### Get User by ID: Access Other User
- [ ] Route: Check user ID matches token user in GET `/api/users/:id`
- [ ] Route: Return 403 if unauthorized
- [ ] Client: Show "Access denied" message
- [ ] Test: `curl -H "Authorization: Bearer user1-token" /api/users/2`

### Get User by ID: Invalid User ID Format
- [ ] Route: Validate ID format in GET `/api/users/:id`
- [ ] Route: Return 400 for invalid ID format
- [ ] Client: Show "Invalid user ID" message
- [ ] Test: `curl -H "Authorization: Bearer token" /api/users/abc`

<br><br><br>




## Global

### `errorHandler`
- [x] Check for RFC7807 error format by checking err.type
- [ ] 

### Authentication: No Auth Token
- [ ] Route: Auth middleware on 
    - [ ] `GET /api/users`
    - [ ] `GET /api/users/:id`
    - [ ] `POST /api/users`
    - [ ] `PUT /api/users/:id`
- [ ] Route: Return 401 if no token
- [ ] Client: Redirect to login page
- [ ] Test: `curl /api/users`

### Authentication: Invalid Token
- [ ] Route: Token validation in auth middleware
- [ ] Route: Return 401 if invalid token
- [ ] Client: Redirect to login page
- [ ] Test: `curl -H "Authorization: Bearer invalid-token" /api/users`

### Authentication: Expired Token
- [ ] Route: Token expiry check in auth middleware
- [ ] Route: Return 401 if token expired
- [ ] Client: Redirect to login page
- [ ] Test: Use expired JWT token

### Authorization: Regular User Access
- [ ] Route: Check user role/permissions in GET `/api/users`
- [ ] Route: Return 403 if not admin/authorized role
- [ ] Client: Show "Access denied" message
- [ ] Test: `curl -H "Authorization: Bearer regular-user-token" /api/users`

### Authorization: Role-Based Access Control
- [ ] Route: Implement role checking middleware
- [ ] Route: Only allow admin/moderator roles
- [ ] Client: Hide admin features from regular users
- [ ] Test: Login as different user roles

### Privacy: Expose Sensitive Data
- [ ] Route: Verify excluded fields in attributes
- [ ] Route: Double-check no PII in response
- [ ] Client: Never display sensitive fields
- [ ] Test: Inspect response for password hashes, tokens, etc.

### Privacy: Email Exposure
- [ ] Route: Consider excluding email from public list
- [ ] Route: Role-based field filtering
- [ ] Client: Show emails only to authorized users
- [ ] Test: Check if emails visible to regular users

### Database: Connection Lost
- [ ] Route: DB error handling with try-catch
- [ ] Route: Return 500 for DB connection errors
- [ ] Client: Show "Service unavailable" error
- [ ] Test: Stop database, make API request

### Database: Query Timeout
- [ ] Route: Set query timeout limits
- [ ] Route: Return 504 for timeout errors
- [ ] Client: Show "Request timeout" error
- [ ] Test: Simulate slow database query