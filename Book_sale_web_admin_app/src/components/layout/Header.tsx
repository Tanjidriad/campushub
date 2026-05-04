import { useTheme } from '@/context/ThemeContext'
import { useAuth } from '@/context/AuthContext'
import { Sun, Moon, Menu, Bell, Search } from 'lucide-react'

interface HeaderProps {
  title: string
  onMobileMenuToggle: () => void
}

export function Header({ title, onMobileMenuToggle }: HeaderProps) {
  const { theme, toggleTheme } = useTheme()
  const { user } = useAuth()

  return (
    <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-[hsl(var(--border))] bg-[hsl(var(--card))] px-6">
      <div className="flex items-center gap-4 flex-1">
        <button
          onClick={onMobileMenuToggle}
          className="rounded-lg p-2 lg:hidden hover:bg-[hsl(var(--accent)/0.1)] transition-colors"
        >
          <Menu className="h-5 w-5" />
        </button>
        <div className="relative w-full max-w-md hidden sm:block">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <Search className="h-4 w-4 text-[hsl(var(--muted-foreground))]" />
          </div>
          <input
            type="text"
            placeholder="Search users, listings, or reports..."
            className="block w-full pl-10 pr-3 py-2 border border-[hsl(var(--border))] rounded-lg text-sm bg-[hsl(var(--muted)/0.3)] text-[hsl(var(--foreground))] placeholder:text-[hsl(var(--muted-foreground))] focus:outline-none focus:ring-1 focus:ring-[hsl(var(--primary))] focus:border-[hsl(var(--primary))] transition-colors"
          />
        </div>
      </div>
      <div className="flex items-center gap-3">
        <button className="relative h-9 w-9 rounded-full flex items-center justify-center hover:bg-[hsl(var(--muted)/0.5)] transition-colors">
          <Bell className="h-[18px] w-[18px] text-[hsl(var(--muted-foreground))]" />
          <span className="absolute right-1.5 top-1.5 h-2 w-2 rounded-full bg-rose-500 ring-2 ring-[hsl(var(--card))]" />
        </button>
        <button onClick={toggleTheme} className="h-9 w-9 rounded-full flex items-center justify-center hover:bg-[hsl(var(--muted)/0.5)] transition-colors">
          {theme === 'light' ? (
            <Moon className="h-[18px] w-[18px] text-[hsl(var(--muted-foreground))]" />
          ) : (
            <Sun className="h-[18px] w-[18px] text-[hsl(var(--muted-foreground))]" />
          )}
        </button>
        {user && (
          <div className="ml-1 flex items-center gap-3 border-l border-[hsl(var(--border))] pl-4">
            <div className="h-8 w-8 rounded-full bg-gradient-to-tr from-[hsl(var(--primary))] to-[hsl(var(--accent))] p-0.5 shadow-sm">
              {user.avatar ? (
                <img
                  src={user.avatar}
                  alt={user.name}
                  className="h-full w-full rounded-full object-cover border-2 border-[hsl(var(--card))]"
                />
              ) : (
                <div className="h-full w-full rounded-full bg-[hsl(var(--card))] flex items-center justify-center text-[10px] font-bold text-[hsl(var(--primary))]">
                  {user.name.charAt(0).toUpperCase()}
                </div>
              )}
            </div>
            <div className="hidden md:block text-xs">
              <p className="font-semibold text-[hsl(var(--foreground))]">{user.name}</p>
              <p className="text-[hsl(var(--muted-foreground))] text-[10px]">{user.email || user.role}</p>
            </div>
          </div>
        )}
      </div>
    </header>
  )
}
