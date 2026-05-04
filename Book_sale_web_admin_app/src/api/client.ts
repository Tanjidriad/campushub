import axios from 'axios'
import { toast } from 'sonner'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'https://campushub-1-kf0n.onrender.com/api'

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 15000,
})

// Request interceptor - attach JWT token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor - handle 401 (auto-logout)
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    // Demo-mode guard: only intercept the specific 403 payload emitted by `book_backend/middleware/demoGuard.js`.
    if (error.response?.status === 403) {
      const data = error.response.data as { code?: string; message?: string } | undefined
      const isDemoMode =
        data?.code === 'DEMO_MODE' || data?.message === 'Action disabled in Demo Mode'

      if (isDemoMode) {
        toast.error("You are in Demo Mode. Cannot save changes.", { duration: 4000 })
      }
    }

    if (error.response?.status === 401) {
      // Token expired or invalid - clear storage and redirect
      localStorage.removeItem('accessToken')
      localStorage.removeItem('refreshToken')
      localStorage.removeItem('user')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default apiClient
