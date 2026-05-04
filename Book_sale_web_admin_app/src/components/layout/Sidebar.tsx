import { NavLink } from 'react-router-dom'
import { cn } from '@/lib/utils'
import { useAuth } from '@/context/AuthContext'
import {
  LayoutDashboard,
  Users,
  BookOpen,
  AlertTriangle,
  FolderOpen,
  GraduationCap,
  Activity,
  ChevronLeft,
  ChevronRight,
  LogOut,
  Clock,
  ScrollText,
} from 'lucide-react'

const navItems = [
  { to: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/users', label: 'Users', icon: Users },
  { to: '/listings', label: 'Listings', icon: BookOpen },
  { to: '/pending', label: 'Pending Review', icon: Clock },
  { to: '/reports', label: 'Reports', icon: AlertTriangle },
  { to: '/categories', label: 'Categories', icon: FolderOpen },
  { to: '/education-config', label: 'Education Config', icon: GraduationCap },
  { to: '/activity', label: 'Activity Feed', icon: Activity },
  { to: '/audit-logs', label: 'Audit Logs & Export', icon: ScrollText },
]

interface SidebarProps {
  collapsed: boolean
  onToggle: () => void
}

export function Sidebar({ collapsed, onToggle }: SidebarProps) {
  const { user, logout } = useAuth()

  return (
    <aside
      className={cn(
        'fixed left-0 top-0 z-40 flex h-screen flex-col border-r border-[hsl(var(--sidebar-border))] bg-[hsl(var(--sidebar-background))] transition-all duration-300 ease-in-out',
        collapsed ? 'w-[72px]' : 'w-[260px]'
      )}
    >
      {/* Logo */}
      <div className="flex h-16 items-center justify-between px-4">
        {!collapsed && (
          <div className="flex items-center gap-3 animate-fade-in">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-[hsl(var(--primary)/0.1)]">
              <GraduationCap className="h-5 w-5 text-[hsl(var(--primary))]" />
            </div>
            <h2 className="text-lg font-bold tracking-tight text-[hsl(var(--sidebar-foreground))] font-display">
              CampusHub
            </h2>
          </div>
        )}
        <button
          onClick={onToggle}
          className="rounded-lg p-1.5 transition-all duration-200 hover:bg-[hsl(var(--sidebar-accent))] text-[hsl(var(--muted-foreground))] hover:text-[hsl(var(--sidebar-foreground))]"
        >
          {collapsed ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
        </button>
      </div>

      {/* Navigation */}
      <nav className="flex-1 space-y-1 overflow-y-auto px-3 py-4">
        {!collapsed && (
          <p className="px-3 text-[10px] font-semibold text-[hsl(var(--muted-foreground))] uppercase tracking-wider mb-3">Admin Menu</p>
        )}
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === '/dashboard'}
            className={({ isActive }) =>
              cn(
                'group relative flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13px] font-medium transition-all duration-200',
                isActive
                  ? 'bg-[hsl(var(--sidebar-primary))] text-white shadow-sm'
                  : 'text-[hsl(var(--muted-foreground))] hover:bg-[hsl(var(--sidebar-accent))] hover:text-[hsl(var(--sidebar-foreground))]',
                collapsed && 'justify-center px-2'
              )
            }
          >
            {({ isActive }) => (
              <>
                <item.icon className={cn(
                  'h-[18px] w-[18px] shrink-0 transition-transform duration-200 group-hover:scale-110',
                  isActive && 'text-white'
                )} />
                {!collapsed && <span>{item.label}</span>}
              </>
            )}
          </NavLink>
        ))}
      </nav>

      {/* User / Logout */}
      <div className="border-t border-[hsl(var(--sidebar-border))] p-3">
        {!collapsed && user && (
          <div className="mb-3 flex items-center gap-3 rounded-lg bg-[hsl(var(--sidebar-accent))] p-2.5">
            <div className="flex h-9 w-9 items-center justify-center rounded-full bg-gradient-to-tr from-[hsl(var(--primary))] to-[hsl(var(--accent))] text-xs font-bold text-white shadow-sm">
              {user.name.charAt(0).toUpperCase()}
            </div>
            <div className="min-w-0">
              <p className="truncate text-sm font-semibold text-[hsl(var(--sidebar-foreground))]">
                {user.name}
              </p>
              <p className="truncate text-[11px] text-[hsl(var(--sidebar-muted))] capitalize">
                {user.role}
              </p>
            </div>
          </div>
        )}
        <button
          onClick={logout}
          className={cn(
            'flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-[hsl(var(--muted-foreground))] transition-all duration-200 hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-950/30 dark:hover:text-red-400',
            collapsed && 'justify-center px-2'
          )}
        >
          <LogOut className="h-[18px] w-[18px] shrink-0" />
          {!collapsed && <span>Logout</span>}
        </button>
      </div>
    </aside>
  )
}
