import { cn } from '@/lib/utils'
import type { ReactNode, HTMLAttributes } from 'react'

interface TableProps extends HTMLAttributes<HTMLTableElement> {
  children: ReactNode
}

export function Table({ className, children, ...props }: TableProps) {
  return (
    <div className="relative w-full overflow-auto">
      <table className={cn('w-full caption-bottom text-sm', className)} {...props}>
        {children}
      </table>
    </div>
  )
}

export function TableHeader({ className, children, ...props }: HTMLAttributes<HTMLTableSectionElement> & { children: ReactNode }) {
  return (
    <thead className={cn('[&_tr]:border-b', className)} {...props}>
      {children}
    </thead>
  )
}

export function TableBody({ className, children, ...props }: HTMLAttributes<HTMLTableSectionElement> & { children: ReactNode }) {
  return (
    <tbody className={cn('[&_tr:last-child]:border-0', className)} {...props}>
      {children}
    </tbody>
  )
}

export function TableRow({ className, children, ...props }: HTMLAttributes<HTMLTableRowElement> & { children: ReactNode }) {
  return (
    <tr
      className={cn(
        'border-b border-[hsl(var(--border))] transition-colors hover:bg-[hsl(var(--muted))]/50',
        className
      )}
      {...props}
    >
      {children}
    </tr>
  )
}

export function TableHead({ className, children, ...props }: HTMLAttributes<HTMLTableCellElement> & { children?: ReactNode }) {
  return (
    <th
      className={cn(
        'h-12 px-4 text-left align-middle font-medium text-[hsl(var(--muted-foreground))] [&:has([role=checkbox])]:pr-0',
        className
      )}
      {...props}
    >
      {children}
    </th>
  )
}

export function TableCell({ className, children, colSpan, ...props }: HTMLAttributes<HTMLTableCellElement> & { children?: ReactNode; colSpan?: number }) {
  return (
    <td colSpan={colSpan} className={cn('p-4 align-middle [&:has([role=checkbox])]:pr-0', className)} {...props}>
      {children}
    </td>
  )
}
