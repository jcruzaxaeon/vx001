// api/middleware/validation.js
// Server-side validation middleware for API routes (no external dependencies)

/**
 * Validation utility functions
 */
const isEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
};

const isStrongPassword = (password) => {
    // At least 8 characters, one uppercase, one lowercase, one number
    const strongPasswordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
    return strongPasswordRegex.test(password);
};

const isValidUsername = (username) => {
    // Only letters, numbers, underscores, and hyphens
    const usernameRegex = /^[a-zA-Z0-9_-]+$/;
    return usernameRegex.test(username);
};

const isPositiveInteger = (value) => {
    const num = parseInt(value, 10);
    return !isNaN(num) && num > 0 && num.toString() === value.toString();
};

/**
 * Validation error formatter !mark
 */
const createValidationError = (field, message, value = null) => ({
    name: 'ValidationError',
    field,
    message,
    value
});

/**
 * Handle validation errors - send formatted error response
 * @param {Array} errors - Array of validation error objects
 * @param {Object} res - Express response object
 * @param {String} message - Optional custom message
 */
export const handleValidationErrors = (errors, res, message = 'Validation failed') => {
    if (!errors || errors.length === 0) {
        return false; // No errors to handle
    }
    
    // Filter out null errors (from commonValidations)
    const validErrors = errors.filter(error => error !== null);
    
    if (validErrors.length === 0) {
        return false; // No actual errors
    }
    
    res.status(400).json({
        success: false,
        message,
        errors: validErrors
    });
    
    return true; // Errors were handled
};

/**
 * User creation validation
 */
export const validateUserCreate = (req, res, next) => {
    const { email, password, username } = req.body;
    const issues = [];

    // ----- PSEUDO-GUARD CLAUSE BLOCK -----
    //
    // ----- EMAIL VALIDATION -----
    //
    // Is email falsy
    if (!email) {
        issues.push({
            name: 'EmailValidationError',
            message: 'Email is required',
            data: {
                field: 'email',
                value: null,
            }
        });
    }
    // Is email not string
    if (email 
        && typeof email !== 'string'){
        //
        issues.push({
                name: 'EmailValidationError',
                message: 'Email must be a string',
                data: {
                    field: 'email',
                    value: email,
            }
        });
    }
    // Is email out of limits
    if (email
        && typeof email === 'string'
        && email.length > 100) {
        //
        issues.push({
            name: 'EmailValidationError',
            message: 'Email must be less than 100 characters',
            data: {
                field: 'email',
                value: email,
            }
        });
    }
    // Is email format invalid
    if (email
        && typeof email === 'string'
        && email.length <= 100
        && !isEmail(email)) {
        //
        issues.push({
            name: 'EmailValidationError',
            message: 'Please provide a valid email address',
            data: {
                field: 'email',
                value: email,
            }
        });
    }

    // ----- PASSWORD VALIDATION -----
    //
    // Password is falsy
    if (!password) {
        issues.push({
            name: 'PasswordValidationError',
            message: 'Password is required',
            data: {
                field: 'password',
                value: null,
            }
        });
    }
    // Is password not a string
    if (password
        && typeof password !== 'string') {
        //
        issues.push({
            name: 'PasswordValidationError',
            message: 'Password must be a string',
            data: {
                field: 'password',
                value: password,
            }
        });
    }
    // Is password out of limits
    if (password
        && typeof password === 'string'
        && (password.length < 8 || password.length > 100)) {
        //
        issues.push({
            name: 'PasswordValidationError',
            message: 'Password must be at least 8 and at most 100 characters long',
            data: {
                field: 'password',
                value: password,
            }
        });
    }
    // Check if password meets strength requirements
    if (password 
        && typeof password === 'string'
        && (password.length >= 8 && password.length <= 100)
        && !isStrongPassword(password)) {
        //
        issues.push({
            name: 'PasswordValidationError',
            message: 'Password must contain at least one uppercase letter, one lowercase letter, and one number',
            data: {
                field: 'password',
                value: password,
            }
        });
    }

    if(issues.length > 0) {
        // RFC7807 error response format
        const error = new Error('Validation failed');
        error.type = '/validation-error';
        error.title = 'Validation Failed';
        error.status = 400;
        error.detail = 'Validation failed for user update';
        error.instance = req.originalUrl;
        error.issues = issues;
        return next(error);
    }

    // ----- USERNAME VALIDATION -----
    // - feature not required for V1, but included for future use
    //
    // Normalize username: treat undefined, null, or empty string as null
    // if (username === undefined
    //     || username === null
    //     || username === '') {
    //     //
    //     req.body.username = null;
    //     username = null; // Update local variable for validation
    // }
    // // Is username not a string
    // if (username
    //     && typeof username !== 'string') {
    //     //
    //     issues.push({
    //         name: 'UsernameValidationError',
    //         message: 'Username must be a string',
    //         data: {
    //             field: 'username',
    //             value: username,
    //         }
    //     });
    // }
    // // Is username out of limits
    // if (username
    //     && typeof username === 'string'
    //     && (username.length < 3 || username.length > 50)) {
    //     //
    //     issues.push({
    //         name: 'UsernameValidationError',
    //         message: 'Username must be between 3 and 50 characters',
    //         data: {
    //             field: 'username',
    //             value: username,
    //         }
    //     });
    // }
    // // Is username format invalid
    // if (username
    //     && typeof username === 'string'
    //     && (username.length >= 3 && username.length <= 50)
    //     && !isValidUsername(username)) {
    //     //
    //     issues.push({
    //         name: 'UsernameValidationError',
    //         message: 'Username can only contain letters, numbers, underscores, and hyphens',
    //         data: {
    //             field: 'username',
    //             value: username,
    //         }
    //     });
    // }

    // Normalize email
    req.body.email = email.toLowerCase().trim();
    
    next();

    // // else if (typeof email !== 'string') {
    // //     issues.push(createValidationError('email', 'Email must be a string', email));
    // // } else if (email.length > 100) {
    // //     issues.push(createValidationError('email', 'Email must be less than 100 characters', email));
    // // } else if (!isEmail(email)) {
    // //     issues.push(createValidationError('email', 'Please provide a valid email address', email));
    // // }

    // // Password validation
    // if (!password) {
    //     issues.push(createValidationError('password', 'Password is required'));
    // } else if (typeof password !== 'string') {
    //     issues.push(createValidationError('password', 'Password must be a string'));
    // } else if (password.length < 8) {
    //     issues.push(createValidationError('password', 'Password must be at least 8 characters long'));
    // } else if (!isStrongPassword(password)) {
    //     issues.push(createValidationError('password', 'Password must contain at least one uppercase letter, one lowercase letter, and one number'));
    // }

    // // Username validation (optional)
    // if (username !== undefined) {
    //     if (username === null || username === '') {
    //         // Allow empty string or null to be treated as no username
    //         req.body.username = null;
    //     } else if (typeof username !== 'string') {
    //         issues.push(createValidationError('username', 'Username must be a string', username));
    //     } else if (username.length < 3 || username.length > 50) {
    //         issues.push(createValidationError('username', 'Username must be between 3 and 50 characters', username));
    //     } else if (!isValidUsername(username)) {
    //         issues.push(createValidationError('username', 'Username can only contain letters, numbers, underscores, and hyphens', username));
    //     }
    // }

    // Return issues if any
    // if (issues.length > 0) {
    //     return res.status(400).json({
    //         success: false,
    //         message: 'Validation failed',
    //         issues
    //     });
    // }

    // // Normalize email
    // req.body.email = email.toLowerCase().trim();
    
    // next();
};

/**
 * User update validation
 */
export const validateUserUpdate = (req, res, next) => {
    const { id } = req.params;
    const { email, password, username } = req.body;
    const errors = [];

    // ID validation
    if (!isPositiveInteger(id)) {
        errors.push(createValidationError('id', 'User ID must be a positive integer', id));
    }

    // Email validation (optional for updates)
    if (email !== undefined) {
        if (typeof email !== 'string') {
            errors.push(createValidationError('email', 'Email must be a string', email));
        } else if (email.length === 0) {
            errors.push(createValidationError('email', 'Email cannot be empty'));
        } else if (email.length > 100) {
            errors.push(createValidationError('email', 'Email must be less than 100 characters', email));
        } else if (!isEmail(email)) {
            errors.push(createValidationError('email', 'Please provide a valid email address', email));
        } else {
            // Normalize email
            req.body.email = email.toLowerCase().trim();
        }
    }

    // Password validation (optional for updates)
    if (password !== undefined) {
        if (typeof password !== 'string') {
            errors.push(createValidationError('password', 'Password must be a string'));
        } else if (password.length === 0) {
            errors.push(createValidationError('password', 'Password cannot be empty'));
        } else if (password.length < 8) {
            errors.push(createValidationError('password', 'Password must be at least 8 characters long'));
        } else if (!isStrongPassword(password)) {
            errors.push(createValidationError('password', 'Password must contain at least one uppercase letter, one lowercase letter, and one number'));
        }
    }

    // Username validation (optional for updates)
    if (username !== undefined) {
        if (username === null || username === '') {
            // Allow setting username to null/empty
            req.body.username = null;
        } else if (typeof username !== 'string') {
            errors.push(createValidationError('username', 'Username must be a string', username));
        } else if (username.length < 3 || username.length > 50) {
            errors.push(createValidationError('username', 'Username must be between 3 and 50 characters', username));
        } else if (!isValidUsername(username)) {
            errors.push(createValidationError('username', 'Username can only contain letters, numbers, underscores, and hyphens', username));
        }
    }

    // ----- V1 -----
    // Return errors if any
    if (errors.length > 0) {
        return res.status(400).json({
            success: false,
            message: 'Validation failed',
            errors
        });
    }

    next();
};

/**
 * User ID parameter validation !mark
 */
export const validateUserId = (req, res, next) => {
    const { id } = req.params;
    const issues = [];

    if (!isPositiveInteger(id)) {
        // issues.push(createValidationError('id', 'User ID must be a positive integer', id));
        issues.push({
            name: 'UserIdValidationError',
            message: 'User ID must be a positive integer',
            data: {
                field: 'user_id',
                value: id,
            }
        });
    }

    if (issues.length > 0) {
        // RFC 7807 error response format
        const error = new Error('Validation failed');
        error.type = '/validation-error';
        error.title = 'Validation Failed';
        error.status = 400;
        error.detail = 'Validation failed for user ID';
        error.instance = req.originalUrl;
        error.issues = issues;

        return next(error);
        // return res.status(400).json({
        //     
        //     type: '/validation-error',
        //     title: 'Validation Failed',
        //     status: 400,
        //     detail: 'Validation failed',
        //     instance: req.originalUrl,
        //     issues
        // });
    }

    next();
};

/**
 * General request body validation
 */
export const validateRequestBody = (req, res, next) => {
    // Check if request has body when expected
    if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
        if (!req.body || Object.keys(req.body).length === 0) {
            return res.status(400).json({
                success: false,
                message: 'Request body is required',
                errors: [createValidationError('body', 'Request body cannot be empty')]
            });
        }
    }
    
    next();
};

/**
 * Common validation functions for reuse
 */
export const commonValidations = {
    /**
     * Validate email field
     */
    email: (value, fieldName = 'email', isRequired = true) => {
        if (!value && isRequired) {
            return createValidationError(fieldName, 'Email is required');
        }
        if (!value && !isRequired) {
            return null; // Optional and not provided
        }
        if (typeof value !== 'string') {
            return createValidationError(fieldName, 'Email must be a string', value);
        }
        if (value.length > 100) {
            return createValidationError(fieldName, 'Email must be less than 100 characters', value);
        }
        if (!isEmail(value)) {
            return createValidationError(fieldName, 'Please provide a valid email address', value);
        }
        return null; // Valid
    },

    /**
     * Validate password field
     */
    password: (value, fieldName = 'password', isRequired = true) => {
        if (!value && isRequired) {
            return createValidationError(fieldName, 'Password is required');
        }
        if (!value && !isRequired) {
            return null; // Optional and not provided
        }
        if (typeof value !== 'string') {
            return createValidationError(fieldName, 'Password must be a string');
        }
        if (value.length < 8) {
            return createValidationError(fieldName, 'Password must be at least 8 characters long');
        }
        if (!isStrongPassword(value)) {
            return createValidationError(fieldName, 'Password must contain at least one uppercase letter, one lowercase letter, and one number');
        }
        return null; // Valid
    },

    /**
     * Validate username field
     */
    username: (value, fieldName = 'username', isRequired = false) => {
        if (!value && isRequired) {
            return createValidationError(fieldName, 'Username is required');
        }
        if (!value && !isRequired) {
            return null; // Optional and not provided
        }
        if (typeof value !== 'string') {
            return createValidationError(fieldName, 'Username must be a string', value);
        }
        if (value.length < 3 || value.length > 50) {
            return createValidationError(fieldName, 'Username must be between 3 and 50 characters', value);
        }
        if (!isValidUsername(value)) {
            return createValidationError(fieldName, 'Username can only contain letters, numbers, underscores, and hyphens', value);
        }
        return null; // Valid
    },

    /**
     * Validate user ID parameter
     */
    userId: (value, fieldName = 'id') => {
        if (!isPositiveInteger(value)) {
            return createValidationError(fieldName, 'User ID must be a positive integer', value);
        }
        return null; // Valid
    }
};