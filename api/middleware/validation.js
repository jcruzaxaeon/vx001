/**
 * Validation Middleware
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>100
 * @file api/middleware/validation.js
 * @description Server-side validation middleware for API routes (no external dependencies)
 */


/**
 * [NEEDED?] Handle validation errors - send formatted error response
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
 * Local Utility Functions (for API Middleware)
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>100
 */
const isEmail = (email) => {
    const emailRegex = /^[a-zA-Z0-9](?:[a-zA-Z0-9._-]{0,61}[a-zA-Z0-9])?@[a-zA-Z0-9](?:[a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?){0,2}\.[a-zA-Z]{2,63}$/;
    return emailRegex.test(email);
};

const isStrongPassword = (password) => {
    // At least 8 characters, one uppercase, one lowercase, one number
    console.log(password);
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
 * Validate Email
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>100
 */
export const validateEmail = (req, res, next) => {
    const { email } = req.body;
    const issues = [];

    // FALSY
    if (!email) {
        issues.push({
            name: 'EmailValidationError',
            message: 'Email is required. Email field cannot be empty.',
            data: {
                field: 'email',
                value: null,
            }
        });
    }

    // NOT STRING
    if (email && 
        typeof email !== 'string') {

        issues.push({
                name: 'EmailValidationError',
                message: 'Email must be a string',
                data: {
                    field: 'email',
                    value: email,
            }
        });
    }

    // BAD LENGTH
    if (email && typeof email !== 'string' && 
        (email.length < 5 || email.length > 254) ) {

        issues.push({
            name: 'EmailValidationError',
            message: 'Email must be less than 100 characters',
            data: {
                field: 'email',
                value: email,
            }
        });
    }

    // BAD FORMAT
    if (email && typeof email === 'string'
        && !isEmail(email)) {

        issues.push({
            name: 'EmailValidationError',
            message: 'Please provide a valid email address',
            data: {
                field: 'email',
                value: email,
            }
        });
    }

    if(issues.length > 0) {
        // RFC7807 error response format
        const error = new Error('Validation failed');
        error.type = '/validation-error';
        error.title = 'Validation Failed';
        error.status = 400;
        error.detail = 'Validation failed for user creation';
        error.instance = req.originalUrl;
        error.issues = issues;
        return next(error);
    }

    req.body.email = email.toLowerCase().trim();
    next();
}

/**
 * Validate Password
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>100
 */
export const validatePassword = (req, res, next) => {
    const { password } = req.body;
    const issues = [];

    // FALSY
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

    // NOT STRING
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

    // BAD LENGTH
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

    console.log(password);
    // WEAK PASSWORD
    if (password 
        && typeof password === 'string'
        && (password.length >= 8 && password.length <= 100)
        && !isStrongPassword(password)) {
        //
        issues.push({
            name: 'PasswordValidationError',
            message: 'Password must contain at least one uppercase letter, one lowercase letter, and one number.',
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

    next();
}

/**
 * Validate ID Number
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>100
 */
export const validateIdNumber = (req, res, next) => {
    const { id } = req.params;
    const issues = [];

    if (!isPositiveInteger(id)) {
        issues.push({
            name: 'IdValidationError',
            message: 'ID must be a positive integer',
            data: {
                field: 'id',
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
        error.detail = 'ID validation failed';
        error.instance = req.originalUrl;
        error.issues = issues;

        return next(error);
    }

    next();
};

/**
 * Validate Body - Body Exists
 */