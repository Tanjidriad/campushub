// ======================== User ========================
export interface User {
  _id: string
  email: string
  username?: string
  name: string
  avatar?: string | null
  phone?: string | null
  bio?: string | null
  location?: string | null
  role: 'student' | 'admin' | 'superadmin'
  isVerified: boolean
  isBlocked: boolean
  isOnline: boolean
  lastActive?: string
  googleId?: string
  totalListings: number
  totalSold: number
  averageRating: number
  totalReviews: number
  createdAt: string
  updatedAt: string
  listingsCount?: number
}

// ======================== Listing ========================
export interface ListingImage {
  url: string
  publicId: string
}

export interface ListingLocation {
  name?: string
  address?: string
  type?: string
  coordinates?: [number, number]
}

export type ListingStatus = 'pending' | 'approved' | 'rejected' | 'sold' | 'expired' | 'hidden' | 'removed'
export type PriceType = 'fixed' | 'negotiable' | 'free' | 'auction'
export type Condition = 'new' | 'like-new' | 'good' | 'fair' | 'poor'

export interface Listing {
  _id: string
  seller: Pick<User, '_id' | 'name' | 'email' | 'avatar'> | string
  title: string
  description: string
  images: ListingImage[]
  category: string
  priceType: PriceType
  price: number
  currency: string
  condition: Condition
  location?: ListingLocation
  meetupPreferences?: string
  status: ListingStatus
  soldTo?: string | null
  soldPrice?: number | null
  soldAt?: string | null
  rejectionReason?: string | null
  removedReason?: string | null
  removedAt?: string | null
  removedBy?: string | null
  views: number
  wishlistCount: number
  inquiries: number
  isFeatured: boolean
  featuredUntil?: string | null
  featuredPlan?: string | null
  approvedBy?: Pick<User, '_id' | 'name'> | string | null
  approvedAt?: string | null
  expiresAt?: string
  tags: string[]
  educationLevel?: string | null
  classOrSemester?: string | null
  subject?: string | null
  bookType?: string | null
  division?: string | null
  district?: string | null
  upazila?: string | null
  createdAt: string
  updatedAt: string
}

// ======================== Report ========================
export type ReportTargetType = 'user' | 'listing' | 'message'
export type ReportReason = 'spam' | 'inappropriate' | 'fraud' | 'harassment' | 'prohibited_item' | 'wrong_category' | 'duplicate' | 'other'
export type ReportStatus = 'pending' | 'reviewed' | 'resolved' | 'dismissed'
export type ActionTaken = 'none' | 'warning' | 'content_removed' | 'user_banned'

export interface Report {
  _id: string
  reporter: Pick<User, '_id' | 'name' | 'email'> | string
  targetType: ReportTargetType
  targetId: string
  targetModel: string
  reason: ReportReason
  description?: string
  status: ReportStatus
  reviewedBy?: Pick<User, '_id' | 'name'> | string | null
  reviewedAt?: string | null
  resolution?: string | null
  actionTaken?: ActionTaken | null
  target?: Partial<User> | Partial<Listing> | null
  createdAt: string
  updatedAt: string
}

// ======================== Category ========================
export interface Category {
  _id: string
  name: string
  slug: string
  description?: string
  icon: string
  image?: string | null
  isActive: boolean
  displayOrder: number
  listingCount: number
  hasEducationConfig?: boolean
  createdAt: string
  updatedAt: string
}

// ======================== Education Config ========================
export interface SubLevel {
  key: string
  label: string
}

export interface EducationDepartment {
  key: string
  label: string
  subLevels: SubLevel[]
}

export interface EducationStream {
  key: string
  label: string
  departments: EducationDepartment[]
}

export interface EducationLevel {
  key: string
  label: string
  subLevels: SubLevel[]
  streams?: EducationStream[]
}

export interface BookType {
  key: string
  label: string
}

export interface EducationConfig {
  _id: string
  levels: EducationLevel[]
  bookTypes: BookType[]
  createdAt: string
  updatedAt: string
}

// ======================== Dashboard ========================
export interface DashboardData {
  users: {
    total: number
    today: number
    thisMonth: number
  }
  listings: {
    total: number
    pending: number
    approved: number
    today: number
  }
  reports: {
    pending: number
  }
  charts: {
    usersByMonth: Array<{ _id: number; count: number }>
    listingsByCategory: Array<{ _id: string; count: number }>
  }
}

// ======================== Activity ========================
export interface Activity {
  id: string
  type: string
  title: string
  subtitle: string
  message: string
  icon: string
  color: 'info' | 'success' | 'warning' | 'error'
  timestamp: string
  createdAt: string
  user?: { _id: string; name: string; avatar?: string }
}

// ======================== Audit Log ========================
export interface AuditLog {
  _id: string
  action: string
  performedBy: Pick<User, '_id' | 'name' | 'email' | 'avatar'> | string
  targetType?: string
  targetId?: string
  details?: Record<string, unknown>
  ip?: string
  createdAt: string
}

// ======================== Pagination ========================
export interface PaginationMeta {
  total: number
  page: number
  limit: number
  totalPages: number
  hasNextPage: boolean
  hasPrevPage: boolean
}

export interface PaginatedResponse<T> {
  success: boolean
  data: T[]
  pagination: PaginationMeta
  statistics?: Record<string, unknown>
}

// ======================== API Response ========================
export interface ApiResponse<T> {
  success: boolean
  data: T
  message?: string
}

// ======================== Auth ========================
export interface LoginResponse {
  user: Pick<User, '_id' | 'email' | 'name' | 'avatar' | 'role' | 'isVerified'> & { id: string }
  accessToken: string
  refreshToken: string
}

export interface AuthUser {
  id: string
  email: string
  name: string
  avatar?: string | null
  role: 'admin' | 'superadmin'
  isVerified: boolean
}
