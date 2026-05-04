import { cn } from '@/lib/utils'
import type { HTMLAttributes } from 'react'

function Avatar({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        'relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full',
        className
      )}
      {...props}
    />
  )
}

function AvatarImage({ src, alt, className }: { src?: string | null; alt?: string; className?: string }) {
  if (!src) return null
  return (
    <img
      src={src}
      alt={alt || ''}
      className={cn('aspect-square h-full w-full object-cover', className)}
    />
  )
}

function AvatarFallback({ className, children, ...props }: HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        'flex h-full w-full items-center justify-center rounded-full bg-[hsl(var(--muted))] text-sm font-medium',
        className
      )}
      {...props}
    >
      {children}
    </div>
  )
}

export { Avatar, AvatarImage, AvatarFallback }
