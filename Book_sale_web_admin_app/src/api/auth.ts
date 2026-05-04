import apiClient from './client'
import type { ApiResponse, LoginResponse } from '@/types'

export const authApi = {
  login: async (email: string, password: string) => {
    const { data } = await apiClient.post<ApiResponse<LoginResponse>>('/auth/login', {
      email,
      password,
    })
    return data.data
  },

  getMe: async () => {
    const { data } = await apiClient.get<ApiResponse<LoginResponse['user']>>('/auth/me')
    return data.data
  },

  refreshToken: async (refreshToken: string) => {
    const { data } = await apiClient.post<ApiResponse<{ accessToken: string; refreshToken: string }>>(
      '/auth/refresh-token',
      { refreshToken }
    )
    return data.data
  },

  logout: async () => {
    await apiClient.post('/auth/logout')
  },
}
