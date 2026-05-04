import { useState } from 'react'
import { useQuery, useMutation } from '@tanstack/react-query'
import { adminApi } from '@/api/admin'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Skeleton } from '@/components/ui/skeleton'
import { toast } from 'sonner'
import {
  ScrollText, Search, Download, Users, BookOpen,
  ChevronLeft, ChevronRight, Shield, Clock,
} from 'lucide-react'
import { format } from 'date-fns'

const ACTION_LABELS: Record<string, { label: string; color: string }> = {
  listing_approved: { label: 'Listing Approved', color: 'text-emerald-600 bg-emerald-50 dark:bg-emerald-950/30' },
  listing_rejected: { label: 'Listing Rejected', color: 'text-red-600 bg-red-50 dark:bg-red-950/30' },
  listing_deleted: { label: 'Listing Deleted', color: 'text-red-700 bg-red-100 dark:bg-red-950/40' },
  listing_featured: { label: 'Listing Featured', color: 'text-amber-600 bg-amber-50 dark:bg-amber-950/30' },
  listing_unfeatured: { label: 'Listing Unfeatured', color: 'text-gray-600 bg-gray-50 dark:bg-gray-950/30' },
  user_banned: { label: 'User Banned', color: 'text-red-600 bg-red-50 dark:bg-red-950/30' },
  user_unbanned: { label: 'User Unbanned', color: 'text-emerald-600 bg-emerald-50 dark:bg-emerald-950/30' },
  role_changed: { label: 'Role Changed', color: 'text-blue-600 bg-blue-50 dark:bg-blue-950/30' },
  report_reviewed: { label: 'Report Reviewed', color: 'text-purple-600 bg-purple-50 dark:bg-purple-950/30' },
}

function getActionInfo(action: string) {
  return ACTION_LABELS[action] || { label: action.replace(/_/g, ' '), color: 'text-gray-600 bg-gray-50 dark:bg-gray-800' }
}

export default function AuditLogsPage() {
  const [page, setPage] = useState(1)
  const [actionFilter, setActionFilter] = useState('')
  const [searchAdmin, setSearchAdmin] = useState('')

  const { data, isLoading } = useQuery({
    queryKey: ['audit-logs', page, actionFilter],
    queryFn: () => adminApi.getAuditLogs({ page, limit: 20, action: actionFilter || undefined }),
  })

  const exportUsersMut = useMutation({
    mutationFn: adminApi.exportUsers,
    onSuccess: () => toast.success('Users CSV downloaded'),
    onError: () => toast.error('Failed to export users'),
  })

  const exportListingsMut = useMutation({
    mutationFn: adminApi.exportListings,
    onSuccess: () => toast.success('Listings CSV downloaded'),
    onError: () => toast.error('Failed to export listings'),
  })

  const logs = data?.data || []
  const pagination = data?.pagination

  if (isLoading) {
    return (
      <div className="space-y-6 animate-fade-in">
        <Skeleton className="h-10 w-60" />
        <Skeleton className="h-12" />
        <Skeleton className="h-96" />
      </div>
    )
  }

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold flex items-center gap-2">
            <ScrollText className="h-5 w-5" /> Audit Logs & Data Export
          </h2>
          <p className="text-sm text-[hsl(var(--muted-foreground))]">
            Track admin actions and export data as CSV
          </p>
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => exportUsersMut.mutate()}
            disabled={exportUsersMut.isPending}
          >
            <Users className="mr-1.5 h-3.5 w-3.5" />
            {exportUsersMut.isPending ? 'Exporting...' : 'Export Users'}
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => exportListingsMut.mutate()}
            disabled={exportListingsMut.isPending}
          >
            <BookOpen className="mr-1.5 h-3.5 w-3.5" />
            {exportListingsMut.isPending ? 'Exporting...' : 'Export Listings'}
          </Button>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="pt-4">
          <div className="flex gap-3 items-center">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[hsl(var(--muted-foreground))]" />
              <Input
                className="pl-9"
                placeholder="Filter by action type (e.g. listing_approved)"
                value={actionFilter}
                onChange={(e) => {
                  setActionFilter(e.target.value)
                  setPage(1)
                }}
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Logs Table */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-base">
            <Shield className="h-5 w-5" />
            Recent Actions
            {pagination && (
              <span className="text-sm font-normal text-[hsl(var(--muted-foreground))]">
                ({pagination.total} total)
              </span>
            )}
          </CardTitle>
        </CardHeader>
        <CardContent>
          {logs.length === 0 ? (
            <p className="py-8 text-center text-sm text-[hsl(var(--muted-foreground))]">
              No audit logs found.
            </p>
          ) : (
            <div className="space-y-2">
              {logs.map((log) => {
                const info = getActionInfo(log.action)
                const admin = typeof log.performedBy === 'object' ? log.performedBy : null
                return (
                  <div
                    key={log._id}
                    className="flex items-center gap-4 rounded-lg border p-3 transition-colors hover:bg-[hsl(var(--muted)/0.3)]"
                  >
                    {/* Action badge */}
                    <span className={`shrink-0 rounded-full px-2.5 py-0.5 text-xs font-medium ${info.color}`}>
                      {info.label}
                    </span>

                    {/* Details */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        {admin && (
                          <span className="text-sm font-medium">{admin.name}</span>
                        )}
                        {log.targetType && (
                          <span className="text-xs text-[hsl(var(--muted-foreground))]">
                            on {log.targetType}
                          </span>
                        )}
                      </div>
                      {log.details && Object.keys(log.details).length > 0 && (
                        <p className="text-xs text-[hsl(var(--muted-foreground))] truncate">
                          {Object.entries(log.details)
                            .map(([k, v]) => `${k}: ${v}`)
                            .join(' · ')}
                        </p>
                      )}
                    </div>

                    {/* Timestamp */}
                    <div className="flex items-center gap-1.5 shrink-0 text-xs text-[hsl(var(--muted-foreground))]">
                      <Clock className="h-3 w-3" />
                      {format(new Date(log.createdAt), 'MMM d, h:mm a')}
                    </div>
                  </div>
                )
              })}
            </div>
          )}

          {/* Pagination */}
          {pagination && pagination.totalPages > 1 && (
            <div className="mt-4 flex items-center justify-between border-t pt-4">
              <p className="text-xs text-[hsl(var(--muted-foreground))]">
                Page {pagination.page} of {pagination.totalPages}
              </p>
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={!pagination.hasPrevPage}
                  onClick={() => setPage((p) => p - 1)}
                >
                  <ChevronLeft className="h-4 w-4" />
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={!pagination.hasNextPage}
                  onClick={() => setPage((p) => p + 1)}
                >
                  <ChevronRight className="h-4 w-4" />
                </Button>
              </div>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
