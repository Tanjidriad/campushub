import apiClient from './client'
import type {
  ApiResponse,
  PaginatedResponse,
  DashboardData,
  Activity,
  AuditLog,
  User,
  Listing,
  Report,
  Category,
  EducationConfig,
} from '@/types'

// ======================== Dashboard ========================
export const adminApi = {
  getDashboard: async () => {
    const { data } = await apiClient.get<ApiResponse<DashboardData>>('/admin/dashboard')
    return data.data
  },

  getActivity: async (limit = 10) => {
    const { data } = await apiClient.get<ApiResponse<Activity[]>>('/admin/activity', {
      params: { limit },
    })
    return data.data
  },

  // ======================== Users ========================
  getUsers: async (params: {
    search?: string
    role?: string
    status?: string
    page?: number
    limit?: number
    sort?: string
  }) => {
    const { data } = await apiClient.get<PaginatedResponse<User> & { statistics: Record<string, number> }>(
      '/admin/users',
      { params }
    )
    return data
  },

  getUser: async (id: string) => {
    const { data } = await apiClient.get<ApiResponse<User>>(`/admin/users/${id}`)
    return data.data
  },

  toggleBan: async (id: string) => {
    const { data } = await apiClient.put<ApiResponse<User> & { message: string }>(`/admin/users/${id}/ban`)
    return data
  },

  changeRole: async (id: string, role: string) => {
    const { data } = await apiClient.put<ApiResponse<User>>(`/admin/users/${id}/role`, { role })
    return data.data
  },

  // ======================== Listings ========================
  getListings: async (params: {
    search?: string
    status?: string
    category?: string
    priceType?: string
    condition?: string
    isFeatured?: string
    minPrice?: string
    maxPrice?: string
    page?: number
    limit?: number
    sort?: string
  }) => {
    const { data } = await apiClient.get<
      PaginatedResponse<Listing> & { statistics: Record<string, unknown> }
    >('/admin/listings', { params })
    return data
  },

  getPendingListings: async (params: { page?: number; limit?: number }) => {
    const { data } = await apiClient.get<PaginatedResponse<Listing>>('/admin/listings/pending', {
      params,
    })
    return data
  },

  approveListing: async (id: string) => {
    const { data } = await apiClient.put<ApiResponse<Listing>>(`/admin/listings/${id}/approve`)
    return data
  },

  rejectListing: async (id: string, reason: string) => {
    const { data } = await apiClient.put<ApiResponse<Listing>>(`/admin/listings/${id}/reject`, {
      reason,
    })
    return data
  },

  deleteListing: async (id: string) => {
    const { data } = await apiClient.delete<ApiResponse<null>>(`/admin/listings/${id}`)
    return data
  },

  toggleFeature: async (id: string) => {
    const { data } = await apiClient.put<ApiResponse<{ isFeatured: boolean }>>(
      `/admin/listings/${id}/feature`
    )
    return data
  },

  bulkApprove: async (listingIds: string[]) => {
    const { data } = await apiClient.post<ApiResponse<{ count: number }>>(
      '/admin/listings/bulk-approve',
      { listingIds }
    )
    return data
  },

  bulkReject: async (listingIds: string[], reason: string) => {
    const { data } = await apiClient.post<ApiResponse<{ count: number }>>(
      '/admin/listings/bulk-reject',
      { listingIds, reason }
    )
    return data
  },

  bulkDelete: async (listingIds: string[]) => {
    const { data } = await apiClient.post<ApiResponse<{ count: number }>>(
      '/admin/listings/bulk-delete',
      { listingIds }
    )
    return data
  },

  // ======================== Reports ========================
  getReports: async (params: {
    status?: string
    targetType?: string
    page?: number
    limit?: number
  }) => {
    const { data } = await apiClient.get<PaginatedResponse<Report>>('/admin/reports', { params })
    return data
  },

  getReportDetail: async (id: string) => {
    const { data } = await apiClient.get<ApiResponse<Report>>(`/admin/reports/${id}`)
    return data.data
  },

  reviewReport: async (
    id: string,
    payload: { status: string; resolution?: string; actionTaken?: string }
  ) => {
    const { data } = await apiClient.put<ApiResponse<Report> & { message: string; actionResult?: unknown }>(
      `/admin/reports/${id}`,
      payload
    )
    return data
  },

  // ======================== Audit Logs ========================
  getAuditLogs: async (params: {
    action?: string
    performedBy?: string
    page?: number
    limit?: number
  }) => {
    const { data } = await apiClient.get<PaginatedResponse<AuditLog>>('/admin/audit-logs', { params })
    return data
  },

  // ======================== Data Export ========================
  exportUsers: async () => {
    const response = await apiClient.get('/admin/export/users', { responseType: 'blob' })
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const a = document.createElement('a')
    a.href = url
    a.download = `campushub-users-${Date.now()}.csv`
    a.click()
    window.URL.revokeObjectURL(url)
  },

  exportListings: async () => {
    const response = await apiClient.get('/admin/export/listings', { responseType: 'blob' })
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const a = document.createElement('a')
    a.href = url
    a.download = `campushub-listings-${Date.now()}.csv`
    a.click()
    window.URL.revokeObjectURL(url)
  },

  // ======================== Education Config ========================
  getEducationConfig: async () => {
    const { data } = await apiClient.get<ApiResponse<EducationConfig>>('/education-config')
    return data.data
  },

  updateEducationConfig: async (payload: {
    levels?: EducationConfig['levels']
    bookTypes?: EducationConfig['bookTypes']
  }) => {
    const { data } = await apiClient.put<ApiResponse<EducationConfig>>(
      '/admin/education-config',
      payload
    )
    return data.data
  },
}

// ======================== Categories ========================
export const categoryApi = {
  getAll: async (includeInactive = true) => {
    const { data } = await apiClient.get<ApiResponse<Category[]>>('/categories', {
      params: { includeInactive },
    })
    return data.data
  },

  getOne: async (id: string) => {
    const { data } = await apiClient.get<ApiResponse<Category>>(`/categories/${id}`)
    return data.data
  },

  create: async (formData: FormData) => {
    const { data } = await apiClient.post<ApiResponse<Category>>('/categories/admin', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    return data.data
  },

  update: async (id: string, formData: FormData) => {
    const { data } = await apiClient.put<ApiResponse<Category>>(`/categories/admin/${id}`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    return data.data
  },

  delete: async (id: string) => {
    const { data } = await apiClient.delete<ApiResponse<null>>(`/categories/admin/${id}`)
    return data
  },

  toggle: async (id: string) => {
    const { data } = await apiClient.patch<ApiResponse<Category>>(`/categories/admin/${id}/toggle`)
    return data.data
  },
}
