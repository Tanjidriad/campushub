import { useEffect, type ReactNode } from 'react'
import { cn } from '@/lib/utils'
import { X } from 'lucide-react'

interface DialogProps {
  open: boolean
  onClose: () => void
  children: ReactNode
  className?: string
}

export function Dialog({ open, onClose, children, className }: DialogProps) {
  useEffect(() => {
    if (open) {
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = ''
    }
    return () => {
      document.body.style.overflow = ''
    }
  }, [open])

  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="fixed inset-0 bg-black/60 backdrop-blur-sm animate-overlay-in" onClick={onClose} />
      <div
        className={cn(
          'relative z-50 w-full max-w-lg rounded-2xl bg-[hsl(var(--background))] p-6 shadow-2xl shadow-black/10 border border-[hsl(var(--border))] max-h-[85vh] overflow-y-auto animate-dialog-in',
          className
        )}
      >
        <button
          onClick={onClose}
          className="absolute right-4 top-4 rounded-full p-1.5 opacity-60 transition-all duration-200 hover:opacity-100 hover:bg-[hsl(var(--muted))] hover:rotate-90"
        >
          <X className="h-4 w-4" />
        </button>
        {children}
      </div>
    </div>
  )
}

export function DialogHeader({ className, children }: { className?: string; children: ReactNode }) {
  return <div className={cn('flex flex-col space-y-1.5 text-center sm:text-left mb-4', className)}>{children}</div>
}

export function DialogTitle({ className, children }: { className?: string; children: ReactNode }) {
  return <h2 className={cn('text-lg font-semibold leading-none tracking-tight', className)}>{children}</h2>
}

export function DialogDescription({ className, children }: { className?: string; children: ReactNode }) {
  return <p className={cn('text-sm text-[hsl(var(--muted-foreground))]', className)}>{children}</p>
}

export function DialogFooter({ className, children }: { className?: string; children: ReactNode }) {
  return (
    <div className={cn('flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2 mt-4', className)}>
      {children}
    </div>
  )
}
