import { cn } from '@/lib/utils'

interface ProgressProps {
  value: number
  max?: number
  className?: string
  indicatorClassName?: string
  showLabel?: boolean
  size?: 'sm' | 'md' | 'lg'
}

export function Progress({
  value,
  max = 100,
  className,
  indicatorClassName,
  showLabel = false,
  size = 'md',
}: ProgressProps) {
  const percentage = Math.min(Math.round((value / max) * 100), 100)

  return (
    <div className={cn('flex items-center gap-3', className)}>
      <div
        className={cn(
          'relative w-full overflow-hidden rounded-full bg-[hsl(var(--muted))]',
          size === 'sm' && 'h-1.5',
          size === 'md' && 'h-2',
          size === 'lg' && 'h-3'
        )}
      >
        <div
          className={cn(
            'h-full rounded-full transition-all duration-700 ease-out',
            'bg-[hsl(var(--primary))]',
            indicatorClassName
          )}
          style={{ width: `${percentage}%` }}
        />
      </div>
      {showLabel && (
        <span className="shrink-0 text-xs font-medium text-[hsl(var(--muted-foreground))]">
          {percentage}%
        </span>
      )}
    </div>
  )
}
