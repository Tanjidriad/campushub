import { cn } from '@/lib/utils'
import type { ReactNode } from 'react'

interface BadgeProps {
  variant?: 'default' | 'secondary' | 'destructive' | 'outline' | 'success' | 'warning'
  className?: string
  children: ReactNode
}

export function Badge({ variant = 'default', className, children }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-medium transition-all duration-200',
        {
          'border-transparent bg-[hsl(var(--primary)/0.12)] text-[hsl(var(--primary))] dark:bg-[hsl(var(--primary)/0.2)]':
            variant === 'default',
          'border-transparent bg-[hsl(var(--secondary))] text-[hsl(var(--secondary-foreground))]':
            variant === 'secondary',
          'border-transparent bg-red-100 text-red-700 dark:bg-red-900/40 dark:text-red-400':
            variant === 'destructive',
          'text-[hsl(var(--foreground))] border-[hsl(var(--border))]': variant === 'outline',
          'border-transparent bg-emerald-100 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-400':
            variant === 'success',
          'border-transparent bg-amber-100 text-amber-700 dark:bg-amber-900/40 dark:text-amber-400':
            variant === 'warning',
        },
        className
      )}
    >
      {children}
    </span>
  )
}
