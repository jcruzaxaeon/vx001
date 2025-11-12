import { useState, useEffect } from 'react';
import { ErrorProvider, useError } from './context/ErrorContext';
import ErrorDisplay from './components/ErrorDisplay';
import { userApi, apiCall } from './services/api';
import './App.css';

// User List Component
const UserList = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const { handleApiError, addSuccess, setIsLoading } = useError();

  // Load users
  const loadUsers = async () => {
    setLoading(true);
    setIsLoading(true);
    
    try {
      const data = await apiCall(
        () => userApi.getAll(),
        handleApiError
      );
      setUsers(data.data);
      console.log('Users loaded:', data.data);
    } catch (error) {
      // Error already handled by handleApiError
    } finally {
      setLoading(false);
      setIsLoading(false);
    }
  };

  // Delete user
  const deleteUser = async (id) => {
    if (!confirm('Are you sure you want to delete this user?')) return;
    
    try {
      await apiCall(
        () => userApi.delete(id),
        handleApiError
      );
      addSuccess('User deleted successfully');
      loadUsers(); // Reload users
    } catch (error) {
      // Error already handled
    }
  };

  useEffect(() => {
    loadUsers();
  }, []);

  if (loading) {
    return <div className="text-center py-4">Loading users...</div>;
  }

  return (
    <div className="user-list">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold">Users</h2>
        <button 
          onClick={loadUsers}
          className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
        >
          Refresh
        </button>
      </div>
      
      {users.length === 0 ? (
        <p className="text-gray-500">No users found</p>
      ) : (
        <div className="space-y-2">
          {users.map(user => (
            <div key={user.id} className="p-4 border rounded-lg flex justify-between items-center">
              <div>
                <h3 className="font-semibold">{user.username}</h3>
                <p className="text-gray-600">{user.email}</p>
              </div>
              <button
                onClick={() => deleteUser(user.id)}
                className="px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600"
              >
                Delete
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

// User Form Component
const UserForm = ({ onUserCreated }) => {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password_hash: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const { handleApiError, addSuccess, clearErrorsByType, ERROR_TYPES } = useError();

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    // Clear validation errors when user starts typing
    clearErrorsByType(ERROR_TYPES.VALIDATION);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      const data = await apiCall(
        () => userApi.create(formData),
        handleApiError
      );
      
      addSuccess('User created successfully');
      setFormData({ username: '', email: '', password_hash: '' });
      
      if (onUserCreated) {
        onUserCreated(data.data);
      }
    } catch (error) {
      // Error already handled
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4 p-4 border rounded-lg">
      <h2 className="text-xl font-bold">Create User</h2>
      
      <div className="grid grid-cols-2 gap-4">
        <input
          type="text"
          name="username"
          placeholder="username"
          value={formData.username}
          onChange={handleInputChange}
          className="p-2 border rounded"
          required
        />
      </div>
      
      <input
        type="email"
        name="email"
        placeholder="Email"
        value={formData.email}
        onChange={handleInputChange}
        className="w-full p-2 border rounded"
        required
      />
      
      <input
        type="password"
        name="password"
        placeholder="Password"
        value={formData.password_hash}
        onChange={handleInputChange}
        className="w-full p-2 border rounded"
        required
      />
      
      <button
        type="submit"
        disabled={isSubmitting}
        className="w-full p-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:opacity-50"
      >
        {isSubmitting ? 'Creating...' : 'Create User'}
      </button>
    </form>
  );
};

// Main App Component
const AppContent = () => {
  const [refreshTrigger, setRefreshTrigger] = useState(0);

  const handleUserCreated = () => {
    setRefreshTrigger(prev => prev + 1);
  };

  return (
    <div className="container mx-auto p-4 max-w-4xl">
      <h1 className="text-3xl font-bold mb-6">User Management System</h1>
      
      <ErrorDisplay />
      
      <div className="grid gap-6">
        <UserForm onUserCreated={handleUserCreated} />
        <UserList key={refreshTrigger} />
      </div>
    </div>
  );
};

// Root App with Error Provider
function App() {
  return (
    <ErrorProvider>
      <AppContent />
    </ErrorProvider>
  );
}

export default App;