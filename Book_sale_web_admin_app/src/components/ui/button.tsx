import { forwardRef, type ButtonHTMLAttributes } from 'react'
import { cn } from '@/lib/utils'

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link'
  size?: 'default' | 'sm' | 'lg' | 'icon'
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'default', size = 'default', ...props }, ref) => {
    return (
      <button
        className={cn(
          'inline-flex items-center justify-center whitespace-nowrap rounded-lg text-sm font-medium transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[hsl(var(--ring))] focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 active:scale-[0.97]',
          {
            'bg-[hsl(var(--primary))] text-[hsl(var(--primary-foreground))] shadow-sm shadow-[hsl(var(--primary)/0.25)] hover:bg-[hsl(var(--primary))]/90 hover:shadow-md hover:shadow-[hsl(var(--primary)/0.3)]':
              variant === 'default',
            'bg-[hsl(var(--destructive))] text-[hsl(var(--destructive-foreground))] shadow-sm shadow-red-500/20 hover:bg-[hsl(var(--destructive))]/90 hover:shadow-md hover:shadow-red-500/25':
              variant === 'destructive',
            'border border-[hsl(var(--input))] bg-[hsl(var(--background))] hover:bg-[hsl(var(--accent))] hover:text-[hsl(var(--accent-foreground))] hover:border-[hsl(var(--primary)/0.3)]':
              variant === 'outline',
            'bg-[hsl(var(--secondary))] text-[hsl(var(--secondary-foreground))] hover:bg-[hsl(var(--secondary))]/80':
              variant === 'secondary',
            'hover:bg-[hsl(var(--accent))] hover:text-[hsl(var(--accent-foreground))]': variant === 'ghost',
            'text-[hsl(var(--primary))] underline-offset-4 hover:underline': variant === 'link',
          },
          {
            'h-10 px-5 py-2': size === 'default',
            'h-9 rounded-lg px-3.5 text-xs': size === 'sm',
            'h-11 rounded-lg px-8': size === 'lg',
            'h-10 w-10': size === 'icon',
          },
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = 'Button'

export { Button }
