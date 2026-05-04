import { useState } from 'react'
import { Outlet, useLocation } from 'react-router-dom'
import { Sidebar } from './Sidebar'
import { Header } from './Header'
import { cn } from '@/lib/utils'

const pageTitles: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/users': 'User Management',
  '/listings': 'Listings',
  '/pending': 'Pending Listings',
  '/reports': 'Reports',
  '/categories': 'Categories',
  '/education-config': 'Education Config',
  '/activity': 'Activity Feed',
}

export function MainLayout() {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)
  const [mobileOpen, setMobileOpen] = useState(false)
  const location = useLocation()

  const title =
    pageTitles[location.pathname] ||
    (location.pathname.startsWith('/users/') ? 'User Details' : 'Admin Panel')

  return (
    <div className="min-h-screen bg-[hsl(var(--background))]">
      {/* Mobile overlay */}
      {mobileOpen && (
        <div
          className="fixed inset-0 z-30 bg-black/50 backdrop-blur-sm lg:hidden animate-overlay-in"
          onClick={() => setMobileOpen(false)}
        />
      )}

      {/* Mobile sidebar */}
      <div
        className={cn(
          'fixed inset-y-0 left-0 z-50 lg:hidden transition-transform duration-300 ease-in-out',
          mobileOpen ? 'translate-x-0' : '-translate-x-full'
        )}
      >
        <Sidebar collapsed={false} onToggle={() => setMobileOpen(false)} />
      </div>

      {/* Desktop sidebar */}
      <div className="hidden lg:block">
        <Sidebar collapsed={sidebarCollapsed} onToggle={() => setSidebarCollapsed(!sidebarCollapsed)} />
      </div>

      {/* Main content */}
      <div
        className={cn(
          'transition-all duration-300 ease-in-out',
          sidebarCollapsed ? 'lg:ml-[72px]' : 'lg:ml-[260px]'
        )}
      >
        <Header title={title} onMobileMenuToggle={() => setMobileOpen(true)} />
        <main className="p-6">
          <div key={location.pathname} className="animate-fade-in">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  )
}
