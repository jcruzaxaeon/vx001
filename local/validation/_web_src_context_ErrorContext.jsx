import { createContext, useContext, useState, useCallback } from 'react';

// Create context
const ErrorContext = createContext();

// Error types
export const ERROR_TYPES = {
  VALIDATION: 'validation',
  NETWORK: 'network',
  AUTH: 'auth',
  SERVER: 'server',
  GENERAL: 'general'
};

// Error Context Provider
export const ErrorProvider = ({ children }) => {
  const [errors, setErrors] = useState([]);
  const [isLoading, setIsLoading] = useState(false);

  // Add error
  const addError = useCallback((error, type = ERROR_TYPES.GENERAL) => {
    const errorObj = {
      id: Date.now() + Math.random(),
      message: typeof error === 'string' ? error : error.message,
      type,
      timestamp: new Date().toISOString(),
      details: typeof error === 'object' ? error : null
    };
    
    setErrors(prev => [...prev, errorObj]);
    
    // Auto-remove after 5 seconds for non-validation errors
    if (type !== ERROR_TYPES.VALIDATION) {
      setTimeout(() => {
        removeError(errorObj.id);
      }, 5000);
    }
  }, []);

  // Add multiple errors (for validation)
  const addErrors = useCallback((errorArray, type = ERROR_TYPES.VALIDATION) => {
    errorArray.forEach(error => addError(error, type));
  }, [addError]);

  // Remove specific error
  const removeError = useCallback((id) => {
    setErrors(prev => prev.filter(error => error.id !== id));
  }, []);

  // Clear all errors
  const clearErrors = useCallback(() => {
    setErrors([]);
  }, []);

  // Clear errors by type
  const clearErrorsByType = useCallback((type) => {
    setErrors(prev => prev.filter(error => error.type !== type));
  }, []);

  // Handle API errors
  const handleApiError = useCallback((error) => {
    console.error('API Error:', error);
    
    if (error.response) {
      const { status, data } = error.response;
      
      if (status === 400 && data.errors) {
        // Validation errors
        addErrors(data.errors.map(err => err.message), ERROR_TYPES.VALIDATION);
      } else if (status === 401) {
        addError('Authentication required', ERROR_TYPES.AUTH);
      } else if (status === 403) {
        addError('Access denied', ERROR_TYPES.AUTH);
      } else if (status === 404) {
        addError('Resource not found', ERROR_TYPES.GENERAL);
      } else if (status >= 500) {
        addError('Server error. Please try again later.', ERROR_TYPES.SERVER);
      } else {
        addError(data.message || 'An error occurred', ERROR_TYPES.GENERAL);
      }
    } else if (error.request) {
      addError('Network error. Please check your connection.', ERROR_TYPES.NETWORK);
    } else {
      addError('An unexpected error occurred', ERROR_TYPES.GENERAL);
    }
  }, [addError, addErrors]);

  // Success message handler
  const [successMessage, setSuccessMessage] = useState(null);
  
  const addSuccess = useCallback((message) => {
    setSuccessMessage(message);
    setTimeout(() => setSuccessMessage(null), 3000);
  }, []);

  const value = {
    errors,
    isLoading,
    successMessage,
    addError,
    addErrors,
    removeError,
    clearErrors,
    clearErrorsByType,
    handleApiError,
    addSuccess,
    setIsLoading
  };

  return (
    <ErrorContext.Provider value={value}>
      {children}
    </ErrorContext.Provider>
  );
};

// Custom hook to use error context
export const useError = () => {
  const context = useContext(ErrorContext);
  if (!context) {
    throw new Error('useError must be used within an ErrorProvider');
  }
  return context;
};