import axios from 'axios';

// Create axios instance
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3001/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
api.interceptors.request.use(
  (config) => {
    // Add auth token if available
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Log error for debugging
    console.error('API Error:', error);
    return Promise.reject(error);
  }
);

// User API methods
export const userApi = {
  // Get all users
  getAll: () => api.get('/users'),
  
  // Get user by ID
  getById: (id) => api.get(`/users/${id}`),
  
  // Create user
  create: (userData) => api.post('/users', userData),
  
  // Update user
  update: (id, userData) => api.put(`/users/${id}`, userData),
  
  // Delete user
  delete: (id) => api.delete(`/users/${id}`)
};

// Generic API helper
export const apiCall = async (apiMethod, errorHandler) => {
  try {
    const response = await apiMethod();
    return response.data;
  } catch (error) {
    if (errorHandler) {
      errorHandler(error);
    }
    throw error;
  }
};

export default api;