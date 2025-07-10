// api/middleware/error-handler.js
// 

/**
 * Centralized error handling middleware for Express applications
 * This should be the LAST middleware in your app (after all routes)
 */

/**
 * Used by:
 * - api/index.js
 * @param {*} err 
 * @param {*} req 
 * @param {*} res 
 * @param {*} next 
 * @returns 
 */
export const errorHandler = (err, req, res, next) => {
    let error = { ...err };
    error.message = err.message;

    // Log error for debugging
    console.error('Error Handler:', err);

    // Default error response
    let response = {
        success: false,
        error: 'Internal Server Error'
    };

    // Check for RFC7807 error format
    if(err.type) {
        return res.status(err.status || 500).json({
            type: err.type,
            title: err.title || 'Unknown Error',
            status: err.status || 500,
            detail: err.detail || 'An unknown error occurred',
            instance: err.instance || req.originalUrl,
            issues: err.issues || []
        })
        // if (err.name === 'ValidationError') {
        //     response = {
        //         success: false,
        //         error: 'Validation Error',
        //         details: err.message,
        //         complete: err
        //     };
        //     return res.status(400).json(response);
        // }
    }

    // Sequelize Validation Error
    if (err.name === 'SequelizeValidationError') {
        const message = err.errors.map(error => error.message).join(', ');
        response = {
            success: false,
            error: 'Validation Error',
            details: message,
            fields: err.errors.map(e => ({
                field: e.path,
                message: e.message,
                value: e.value
            }))
        };
        return res.status(400).json(response);
    }

    // Sequelize Unique Constraint Error
    if (err.name === 'SequelizeUniqueConstraintError') {
        const field = err.errors[0]?.path || 'field';
        const message = `${field.charAt(0).toUpperCase() + field.slice(1)} already exists`;
        response = {
            success: false,
            error: 'Duplicate Entry',
            details: message,
            field: field
        };
        return res.status(409).json(response);
    }

    // Sequelize Database Connection Error
    if (err.name === 'SequelizeConnectionError') {
        response = {
            success: false,
            error: 'Database Connection Error',
            details: 'Unable to connect to database'
        };
        return res.status(503).json(response);
    }

    // Sequelize Foreign Key Constraint Error
    if (err.name === 'SequelizeForeignKeyConstraintError') {
        response = {
            success: false,
            error: 'Reference Error',
            details: 'Referenced record does not exist'
        };
        return res.status(400).json(response);
    }

    // Custom Application Errors (for future use)


    if (err.name === 'NotFoundError') {
        response = {
            success: false,
            error: 'Not Found',
            details: err.message
        };
        return res.status(404).json(response);
    }

    if (err.name === 'AuthenticationError') {
        response = {
            success: false,
            error: 'Authentication Error',
            details: err.message
        };
        return res.status(401).json(response);
    }

    if (err.name === 'AuthorizationError') {
        response = {
            success: false,
            error: 'Authorization Error',
            details: err.message
        };
        return res.status(403).json(response);
    }

    // Handle specific HTTP status codes
    if (err.statusCode) {
        response = {
            success: false,
            error: err.message || 'Error occurred',
            details: err.details || null
        };
        return res.status(err.statusCode).json(response);
    }

    // Default 500 error
    response = {
        success: false,
        error: 'Internal Server Error',
        details: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
    };
    
    res.status(500).json(response);
};

/**
 * Async handler wrapper to eliminate try/catch blocks in routes
 * Automatically catches async errors and passes them to next() for error handling
 * 
 * Usage:
 * router.get('/path', asyncHandler(async (req, res) => {
 *   // Your async code here - no try/catch needed!
 *   const data = await SomeModel.findAll();
 *   res.json(data);
 * }));
 */

export const asyncHandler = (fn) => {
    return (req, res, next) => {
        // Execute the function and catch any promise rejections
        Promise.resolve(fn(req, res, next)).catch(next);
    };
};