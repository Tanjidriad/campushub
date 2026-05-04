import { createContext, useContext, useEffect, useState, useCallback, type ReactNode } from 'react'
import type { AuthUser } from '@/types'
import { authApi } from '@/api/auth'

interface AuthContextType {
  user: AuthUser | null
  isAuthenticated: boolean
  isLoading: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  // Initialize from localStorage
  useEffect(() => {
    const storedUser = localStorage.getItem('user')
    const token = localStorage.getItem('accessToken')
    if (storedUser && token) {
      try {
        const parsed = JSON.parse(storedUser) as AuthUser
        if (parsed.role === 'admin' || parsed.role === 'superadmin') {
          setUser(parsed)
        } else {
          // Not an admin — clear
          localStorage.removeItem('user')
          localStorage.removeItem('accessToken')
          localStorage.removeItem('refreshToken')
        }
      } catch {
        localStorage.removeItem('user')
      }
    }
    setIsLoading(false)
  }, [])

  const login = useCallback(async (email: string, password: string) => {
    const result = await authApi.login(email, password)
    const authUser: AuthUser = {
      id: result.user.id || result.user._id,
      email: result.user.email,
      name: result.user.name,
      avatar: result.user.avatar,
      role: result.user.role as 'admin' | 'superadmin',
      isVerified: result.user.isVerified,
    }

    // Validate admin role
    if (authUser.role !== 'admin' && authUser.role !== 'superadmin') {
      throw new Error('Access denied. Admin privileges required.')
    }

    localStorage.setItem('accessToken', result.accessToken)
    localStorage.setItem('refreshToken', result.refreshToken)
    localStorage.setItem('user', JSON.stringify(authUser))
    setUser(authUser)
  }, [])

  const logout = useCallback(() => {
    authApi.logout().catch(() => {})
    localStorage.removeItem('accessToken')
    localStorage.removeItem('refreshToken')
    localStorage.removeItem('user')
    setUser(null)
  }, [])

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        isLoading,
        login,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
