import { useQuery } from '@tanstack/react-query'
import { adminApi } from '@/api/admin'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { timeAgo } from '@/lib/utils'
import {
  UserPlus,
  BookPlus,
  ShieldAlert,
  CheckCircle,
  XCircle,
  Star,
  Ban,
  Trash2,
  type LucideIcon,
} from 'lucide-react'

const actionMeta: Record<string, { icon: LucideIcon; color: string; label: string }> = {
  user_registered: { icon: UserPlus, color: 'text-blue-500', label: 'User Registered' },
  listing_created: { icon: BookPlus, color: 'text-green-500', label: 'Listing Created' },
  listing_approved: { icon: CheckCircle, color: 'text-green-600', label: 'Listing Approved' },
  listing_rejected: { icon: XCircle, color: 'text-red-500', label: 'Listing Rejected' },
  listing_featured: { icon: Star, color: 'text-yellow-500', label: 'Listing Featured' },
  listing_deleted: { icon: Trash2, color: 'text-red-600', label: 'Listing Deleted' },
  user_banned: { icon: Ban, color: 'text-red-600', label: 'User Banned' },
  user_unbanned: { icon: CheckCircle, color: 'text-green-500', label: 'User Unbanned' },
  report_created: { icon: ShieldAlert, color: 'text-orange-500', label: 'Report Filed' },
  report_resolved: { icon: CheckCircle, color: 'text-green-500', label: 'Report Resolved' },
}

const defaultMeta = { icon: CheckCircle, color: 'text-[hsl(var(--muted-foreground))]', label: 'Activity' }

export default function ActivityFeedPage() {
  const { data: activities, isLoading } = useQuery({
    queryKey: ['activity', 50],
    queryFn: () => adminApi.getActivity(50),
    refetchInterval: 30_000,
  })

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold font-display">Activity Feed</h2>
          <p className="text-sm text-[hsl(var(--muted-foreground))] mt-1">
            Recent platform activity in real-time
          </p>
        </div>
      </div>

      <div className="bg-[hsl(var(--card))] rounded-xl border border-[hsl(var(--border))] shadow-sm overflow-hidden">
          {isLoading ? (
            <div className="space-y-4 p-6">
              {Array.from({ length: 8 }).map((_, i) => (
                <div key={i} className="flex items-start gap-4">
                  <Skeleton className="h-10 w-10 rounded-full shrink-0" />
                  <div className="flex-1 space-y-2">
                    <Skeleton className="h-4 w-3/4" />
                    <Skeleton className="h-3 w-1/4" />
                  </div>
                </div>
              ))}
            </div>
          ) : activities && activities.length > 0 ? (
            <div className="divide-y divide-[hsl(var(--border))]">
              {activities.map((activity, idx) => {
                const meta = actionMeta[activity.type] || defaultMeta
                const Icon = meta.icon

                return (
                  <div key={idx} className="flex items-start gap-4 px-6 py-4 hover:bg-[hsl(var(--muted)/0.3)] transition-colors">
                    <div className={`h-9 w-9 rounded-full flex items-center justify-center shrink-0 ${meta.color.replace('text-', 'bg-').replace('500', '100').replace('600', '100')} dark:bg-opacity-20`}>
                      <Icon className={`h-4 w-4 ${meta.color}`} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-[10px] font-semibold uppercase tracking-wider ${
                          meta.color.includes('green') ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/20 dark:text-emerald-400' :
                          meta.color.includes('red') ? 'bg-rose-100 text-rose-700 dark:bg-rose-900/20 dark:text-rose-400' :
                          meta.color.includes('blue') ? 'bg-blue-100 text-blue-700 dark:bg-blue-900/20 dark:text-blue-400' :
                          meta.color.includes('yellow') || meta.color.includes('orange') ? 'bg-amber-100 text-amber-700 dark:bg-amber-900/20 dark:text-amber-400' :
                          'bg-[hsl(var(--muted))] text-[hsl(var(--muted-foreground))]'
                        }`}>
                          {meta.label}
                        </span>
                        <span className="text-xs text-[hsl(var(--muted-foreground))]">
                          {timeAgo(activity.timestamp || activity.createdAt)}
                        </span>
                      </div>
                      <p className="mt-1 text-sm">{activity.message}</p>
                      {activity.user && (
                        <p className="mt-0.5 text-xs text-[hsl(var(--muted-foreground))]">
                          by {activity.user.name}
                        </p>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          ) : (
            <p className="py-12 text-center text-sm text-[hsl(var(--muted-foreground))]">
              No recent activity
            </p>
          )}
      </div>
    </div>
  )
}
