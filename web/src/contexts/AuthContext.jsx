// ./web/src/context/AuthContext.jsx

/**
 * @todo [ ] fix(web): api expects /api/users/:id not /api/auth/me
 */

import {
    createContext,
    useContext,
    useState,
    useEffect,
    useRef } from 'react'

const AuthContext = createContext(null)
const API_BASE = 'http://localhost:3001'

export function AuthProvider({ children }) {
    const [user, setUser] = useState(null)
    const [loading, setLoading] = useState(true)
    const hasCheckedAuth = useRef(false);
    // const [hasCheckedAuth, setHasCheckedAuth] = useState(false)

    const checkAuth = async () => {
        if(hasCheckedAuth.current) return
        hasCheckedAuth.current = true

        try {
            const res = await fetch(`${API_BASE}/api/auth/me`, { //Error logs 2x on this line
                credentials: 'include'
            })
            if (res.ok) {
                const info = await res.json()
                setUser(info.data)
            } else {
                setUser(null)
            }
        } 
        
        catch (err) {
            setUser(null)
            console.error('Auth check failed:', err)
        } 
        
        finally {
            setLoading(false)
        }
    }

    const login = async (email, password) => {
        const response = await fetch(`${API_BASE}/api/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({ email, password })
        });
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.detail || 'Login failed');
        }
        const info = await response.json();
        setUser(info.data); // Update user immediately!
        return info;
    };

    // const login = (userData) => {
    //     setUser(userData)
    // }

    const logout = async () => {
        try {
            await fetch(`${API_BASE}/api/auth/logout`, {
                method: 'POST',
                credentials: 'include'
            })
            setUser(null)
        } catch (err) {
        console.error('Logout failed:', err)
        }
    }

    const clearUser = () => {
        setUser(null)
    }

    useEffect(() => {
        // if(!hasCheckedAuth) checkAuth()
        checkAuth()
    }, [])

    return (
        <AuthContext.Provider value={{ user, loading, logout, login, checkAuth, clearUser }}>
        {children}
        </AuthContext.Provider>
    )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}