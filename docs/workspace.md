feat(api): update validation

- [?] check/update/document email, username, password validation rules in `resilience.md`

feat(e2e): normalize error messages

- [ ] create consistent/global format for validation and db errors

feat(web): 

- [ ] add field specific error-messages
- [ ] create a consistent web-client error display system

## Stage 5: Enhanced Error Responses
**Commit: "Improve validation error responses"**
- Update error handler to format validation errors consistently
- Add field-specific error messages
- ***Test client-side error display***

## Stage 6: Request Sanitization
**Commit: "Add input sanitization middleware"**
- Add basic sanitization (trim whitespace, escape HTML)
- Apply to user input fields
- Test with various input scenarios

**Optional Stage 7: Validation Schema Organization**
**Commit: "Refactor validation into schema-based approach"**
- Organize validation rules into reusable schemas
- Create validation middleware that accepts schema parameters

Each stage builds on the previous one and can be thoroughly tested before moving forward. The async handler is definitely worth implementing - it'll clean up your route code significantly and make error handling more consistent.

Would you like me to elaborate on any specific stage or help you implement the first one?

---

Looking at your progress, you're at a great spot for implementing validation next. Let me address your questions:

**Server-side vs Client-side Validation:**
You're absolutely right to question this. For an MVP, you can definitely rely on server-side validation and display the error responses on the client. This is actually a solid approach because:
- Server-side validation is your security layer (never trust client input)
- Client-side validation is just UX enhancement
- Displaying server errors on the client IS a form of client-side validation handling

**Recommended Next Stage:**

**Stage: Server-side Validation Middleware**
This should be your next commit because:
1. It's a natural progression from error handling
2. It's backend-focused (matching your current momentum)
3. It provides immediate value for data integrity
4. It's a complete, testable feature in one commit

**What this stage should include:**
- `api/middleware/validation.js` - validation middleware functions
- Validation rules for user model (email format, password strength, etc.)
- Integration with your existing error handler
- Update user routes to use validation
- Test the validation in your `api-test.sh`

**Future stages after this:**
1. **Stage 2:** Client-side error display (consume server validation responses)
2. **Stage 3:** Authentication middleware (you have JWT/bcrypt ready)
3. **Stage 4:** Basic CRUD operations for your second model (nodes?)
4. **Stage 5:** Client-side forms with server integration

This approach keeps each commit focused and builds logically on your error handling foundation. The validation middleware will work perfectly with your existing `errorHandler` and `asyncHandler`.

Would you like me to help outline the specific validation middleware implementation for your next commit?

---

# !!!
No, `express-validator` is not included with Express - it's a separate dependency. Let me rewrite the validation middleware without additional dependencies.Perfect! Now you have validation middleware without external dependencies. 

**To integrate this into your routes, you'll need to:**

1. **Update your `user-routes.js`** to import and use the validation middleware:
   ```javascript
   import { validateUserCreate, validateUserUpdate, validateUserId } from '../middleware/validation.js';
   
   // Apply to your routes:
   router.post('/users', validateUserCreate, createUser);
   router.put('/users/:id', validateUserUpdate, updateUser);
   router.get('/users/:id', validateUserId, getUserById);
   router.delete('/users/:id', validateUserId, deleteUser);
   ```

2. **Add the validation test calls** to your `main()` function in `api-test.sh` as shown in the comment at the bottom of the test additions.

This validation middleware will:
- Check all required fields and data types
- Validate email format and normalize it (lowercase, trim)
- Enforce strong password requirements (8+ chars, uppercase, lowercase, number)
- Validate username format (3-50 chars, alphanumeric + underscore/hyphen)
- Validate user ID parameters are positive integers
- Return consistent error format that matches your existing error handling

The tests cover all the validation scenarios including edge cases. This should be a solid foundation for your validation layer!

## Complete

### Stage 1: Basic Error Handler Middleware
**Commit: "Add centralized error handling middleware"**
- Create `middleware/errorHandler.js` with basic error formatting
- Add it as the last middleware in your Express app
- Test with existing routes to ensure errors are caught properly

### Stage 2: Async Handler Utility
**Commit: "Add async handler wrapper for route protection"**
- Create `middleware/asyncHandler.js` (yes, it's useful - eliminates repetitive try/catch)
- Wrap one existing route to test functionality
- Verify error handling still works with the wrapper

## Stage 3: Basic Validation Middleware Structure
**Commit: "Create validation middleware foundation"**
- Create `middleware/validation.js` with basic structure
- Add a simple validation function (like `validateRequired`)
- Apply to one field on one route (e.g., email required on user creation)

## Stage 4: User Model Validation Rules
**Commit: "Add comprehensive user validation rules"**
- Expand validation.js with user-specific validators:
  - Email format validation
  - Password strength requirements
  - Username constraints
- Apply to all user routes (create, update)