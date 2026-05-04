import { cn } from '@/lib/utils'

export function Skeleton({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        'rounded-xl bg-gradient-to-r from-[hsl(var(--muted))] via-[hsl(var(--muted)/0.5)] to-[hsl(var(--muted))] animate-shimmer',
        className
      )}
      {...props}
    />
  )
}
