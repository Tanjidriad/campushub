import { lazy, Suspense } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import ProtectedRoute from '@/components/ProtectedRoute'
import { MainLayout } from '@/components/layout/MainLayout'

// Lazy-loaded pages
const LoginPage = lazy(() => import('@/features/auth/LoginPage'))
const DashboardPage = lazy(() => import('@/features/dashboard/DashboardPage'))
const UsersPage = lazy(() => import('@/features/users/UsersPage'))
const UserDetailPage = lazy(() => import('@/features/users/UserDetailPage'))
const ListingsPage = lazy(() => import('@/features/listings/ListingsPage'))
const ReportsPage = lazy(() => import('@/features/reports/ReportsPage'))
const CategoriesPage = lazy(() => import('@/features/categories/CategoriesPage'))
const EducationConfigPage = lazy(() => import('@/features/education-config/EducationConfigPage'))
const ActivityFeedPage = lazy(() => import('@/features/activity/ActivityFeedPage'))
const AuditLogsPage = lazy(() => import('@/features/audit-logs/AuditLogsPage'))
const NotFoundPage = lazy(() => import('@/features/NotFoundPage'))

function PageLoader() {
  return (
    <div className="flex h-64 items-center justify-center animate-fade-in">
      <div className="relative">
        <div className="h-10 w-10 animate-spin rounded-full border-4 border-[hsl(var(--primary)/0.2)] border-t-[hsl(var(--primary))]" />
        <div className="absolute inset-0 h-10 w-10 animate-ping rounded-full border-4 border-[hsl(var(--primary)/0.1)]" style={{ animationDuration: '2s' }} />
      </div>
    </div>
  )
}

export default function App() {
  return (
    <Suspense fallback={<PageLoader />}>
      <Routes>
        {/* Public */}
        <Route path="/login" element={<LoginPage />} />

        {/* Protected */}
        <Route element={<ProtectedRoute />}>
          <Route element={<MainLayout />}>
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="dashboard" element={<DashboardPage />} />
            <Route path="users" element={<UsersPage />} />
            <Route path="users/:id" element={<UserDetailPage />} />
            <Route path="listings" element={<ListingsPage />} />
            <Route path="pending" element={<ListingsPage pendingOnly />} />
            <Route path="reports" element={<ReportsPage />} />
            <Route path="categories" element={<CategoriesPage />} />
            <Route path="education-config" element={<EducationConfigPage />} />
            <Route path="activity" element={<ActivityFeedPage />} />
            <Route path="audit-logs" element={<AuditLogsPage />} />
            <Route path="*" element={<NotFoundPage />} />
          </Route>
        </Route>

        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </Suspense>
  )
}
