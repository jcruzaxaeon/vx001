import { useError, ERROR_TYPES } from '../context/ErrorContext';

const ErrorDisplay = () => {
  const { errors, successMessage, removeError } = useError();

  if (errors.length === 0 && !successMessage) {
    return null;
  }

  const getErrorStyles = (type) => {
    const baseStyles = "p-4 mb-4 rounded-lg border-l-4 relative";
    
    switch (type) {
      case ERROR_TYPES.VALIDATION:
        return `${baseStyles} bg-yellow-50 border-yellow-400 text-yellow-800`;
      case ERROR_TYPES.NETWORK:
        return `${baseStyles} bg-orange-50 border-orange-400 text-orange-800`;
      case ERROR_TYPES.AUTH:
        return `${baseStyles} bg-red-50 border-red-400 text-red-800`;
      case ERROR_TYPES.SERVER:
        return `${baseStyles} bg-red-50 border-red-400 text-red-800`;
      default:
        return `${baseStyles} bg-red-50 border-red-400 text-red-800`;
    }
  };

  const getErrorIcon = (type) => {
    switch (type) {
      case ERROR_TYPES.VALIDATION:
        return "⚠️";
      case ERROR_TYPES.NETWORK:
        return "🌐";
      case ERROR_TYPES.AUTH:
        return "🔒";
      case ERROR_TYPES.SERVER:
        return "🔧";
      default:
        return "❌";
    }
  };

  return (
    <div className="error-display">
      {/* Success Message */}
      {successMessage && (
        <div className="p-4 mb-4 rounded-lg border-l-4 bg-green-50 border-green-400 text-green-800 relative">
          <div className="flex items-center">
            <span className="mr-2">✅</span>
            <span>{successMessage}</span>
          </div>
        </div>
      )}

      {/* Error Messages */}
      {errors.map((error) => (
        <div key={error.id} className={getErrorStyles(error.type)}>
          <div className="flex items-start justify-between">
            <div className="flex items-start">
              <span className="mr-2 text-lg">{getErrorIcon(error.type)}</span>
              <div>
                <p className="font-medium">{error.message}</p>
                {error.details && (
                  <pre className="mt-2 text-sm opacity-75">
                    {JSON.stringify(error.details, null, 2)}
                  </pre>
                )}
              </div>
            </div>
            <button
              onClick={() => removeError(error.id)}
              className="text-xl opacity-50 hover:opacity-100 transition-opacity"
              aria-label="Close error"
            >
              ×
            </button>
          </div>
        </div>
      ))}
    </div>
  );
};

export default ErrorDisplay;