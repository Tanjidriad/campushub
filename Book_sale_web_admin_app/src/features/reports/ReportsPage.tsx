import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '@/api/admin'
import { usePagination } from '@/hooks/usePagination'
import { Button } from '@/components/ui/button'
import { Select } from '@/components/ui/select'
import { Textarea } from '@/components/ui/textarea'
import { Pagination } from '@/components/ui/pagination'
import { Skeleton } from '@/components/ui/skeleton'
import { toast } from 'sonner'
import {
  Flag,
  AlertTriangle,
  UserX,
  MessageSquareWarning,
  X,
  ShieldAlert,
  ExternalLink,
  Send,
  Shield,
  Clock,
  CheckCircle2,
  XCircle,
  Eye,
  Trash2,
  Ban,
  ChevronRight,
  User,
} from 'lucide-react'
import { capitalize, timeAgo } from '@/lib/utils'
import type { Report, ReportStatus, ReportReason, Listing, User as TUser } from '@/types'

/* ─── Reason → visual meta ─── */
interface ReasonMeta {
  icon: typeof Flag
  stripeBg: string
  iconBg: string
  iconColor: string
  glowColor: string
  accentRing: string
  gradient: string
  reasonBg: string
  reasonBorder: string
  reasonText: string
}
const reasonMeta: Record<string, ReasonMeta> = {
  inappropriate: { icon: Flag, stripeBg: 'bg-gradient-to-b from-red-500 to-rose-400', iconBg: 'bg-gradient-to-br from-red-500/20 to-rose-400/10', iconColor: 'text-red-500', glowColor: 'shadow-red-500/5', accentRing: 'ring-red-500/20', gradient: 'from-red-500 to-rose-500', reasonBg: 'bg-rose-100 dark:bg-rose-900/20', reasonBorder: 'border-rose-200 dark:border-rose-800/30', reasonText: 'text-rose-700 dark:text-rose-400' },
  harassment: { icon: UserX, stripeBg: 'bg-gradient-to-b from-red-500 to-rose-400', iconBg: 'bg-gradient-to-br from-red-500/20 to-rose-400/10', iconColor: 'text-red-500', glowColor: 'shadow-red-500/5', accentRing: 'ring-red-500/20', gradient: 'from-red-500 to-rose-500', reasonBg: 'bg-rose-100 dark:bg-rose-900/20', reasonBorder: 'border-rose-200 dark:border-rose-800/30', reasonText: 'text-rose-700 dark:text-rose-400' },
  prohibited_item: { icon: ShieldAlert, stripeBg: 'bg-gradient-to-b from-red-500 to-rose-400', iconBg: 'bg-gradient-to-br from-red-500/20 to-rose-400/10', iconColor: 'text-red-500', glowColor: 'shadow-red-500/5', accentRing: 'ring-red-500/20', gradient: 'from-red-500 to-rose-500', reasonBg: 'bg-rose-100 dark:bg-rose-900/20', reasonBorder: 'border-rose-200 dark:border-rose-800/30', reasonText: 'text-rose-700 dark:text-rose-400' },
  fraud: { icon: ShieldAlert, stripeBg: 'bg-gradient-to-b from-amber-500 to-yellow-400', iconBg: 'bg-gradient-to-br from-amber-500/20 to-yellow-400/10', iconColor: 'text-amber-500', glowColor: 'shadow-amber-500/5', accentRing: 'ring-amber-500/20', gradient: 'from-amber-500 to-yellow-500', reasonBg: 'bg-amber-100 dark:bg-amber-900/20', reasonBorder: 'border-amber-200 dark:border-amber-800/30', reasonText: 'text-amber-700 dark:text-amber-400' },
  spam: { icon: MessageSquareWarning, stripeBg: 'bg-gradient-to-b from-blue-500 to-indigo-400', iconBg: 'bg-gradient-to-br from-blue-500/20 to-indigo-400/10', iconColor: 'text-blue-500', glowColor: 'shadow-blue-500/5', accentRing: 'ring-blue-500/20', gradient: 'from-blue-500 to-indigo-500', reasonBg: 'bg-blue-100 dark:bg-blue-900/20', reasonBorder: 'border-blue-200 dark:border-blue-800/30', reasonText: 'text-blue-700 dark:text-blue-400' },
  wrong_category: { icon: AlertTriangle, stripeBg: 'bg-gradient-to-b from-slate-400 to-slate-300', iconBg: 'bg-gradient-to-br from-slate-400/20 to-slate-300/10', iconColor: 'text-slate-500', glowColor: 'shadow-slate-400/5', accentRing: 'ring-slate-400/20', gradient: 'from-slate-400 to-slate-500', reasonBg: 'bg-slate-100 dark:bg-slate-800/50', reasonBorder: 'border-slate-200 dark:border-slate-700', reasonText: 'text-slate-600 dark:text-slate-400' },
  duplicate: { icon: AlertTriangle, stripeBg: 'bg-gradient-to-b from-slate-400 to-slate-300', iconBg: 'bg-gradient-to-br from-slate-400/20 to-slate-300/10', iconColor: 'text-slate-500', glowColor: 'shadow-slate-400/5', accentRing: 'ring-slate-400/20', gradient: 'from-slate-400 to-slate-500', reasonBg: 'bg-slate-100 dark:bg-slate-800/50', reasonBorder: 'border-slate-200 dark:border-slate-700', reasonText: 'text-slate-600 dark:text-slate-400' },
  other: { icon: AlertTriangle, stripeBg: 'bg-gradient-to-b from-slate-400 to-slate-300', iconBg: 'bg-gradient-to-br from-slate-400/20 to-slate-300/10', iconColor: 'text-slate-500', glowColor: 'shadow-slate-400/5', accentRing: 'ring-slate-400/20', gradient: 'from-slate-400 to-slate-500', reasonBg: 'bg-slate-100 dark:bg-slate-800/50', reasonBorder: 'border-slate-200 dark:border-slate-700', reasonText: 'text-slate-600 dark:text-slate-400' },
}
const defaultMeta = reasonMeta.other

/* Status config for cards (with border) */
const statusConfig: Record<string, { bg: string; text: string; dot: string; border: string }> = {
  pending: { bg: 'bg-amber-500/10', text: 'text-amber-700 dark:text-amber-400', dot: 'bg-amber-500', border: 'border-amber-500/20' },
  reviewed: { bg: 'bg-blue-500/10', text: 'text-blue-700 dark:text-blue-400', dot: 'bg-blue-500', border: 'border-blue-500/20' },
  resolved: { bg: 'bg-emerald-500/10', text: 'text-emerald-700 dark:text-emerald-400', dot: 'bg-emerald-500', border: 'border-emerald-500/20' },
  dismissed: { bg: 'bg-slate-500/10', text: 'text-slate-600 dark:text-slate-400', dot: 'bg-slate-400', border: 'border-slate-500/20' },
}

type Severity = 'critical' | 'high' | 'medium' | 'low'
const reasonSeverity: Record<string, Severity> = {
  inappropriate: 'high', harassment: 'critical', prohibited_item: 'critical',
  fraud: 'high', spam: 'medium', wrong_category: 'low', duplicate: 'low', other: 'low',
}
const severityLabel: Record<Severity, { label: string; color: string }> = {
  critical: { label: 'Critical', color: 'text-red-600 dark:text-red-400' },
  high: { label: 'High', color: 'text-amber-600 dark:text-amber-400' },
  medium: { label: 'Medium', color: 'text-blue-600 dark:text-blue-400' },
  low: { label: 'Low', color: 'text-slate-500 dark:text-slate-400' },
}

/* Status badge config for detail panel */
const statusBadge: Record<string, { bg: string; text: string; dot: string }> = {
  pending: { bg: 'bg-amber-100 dark:bg-amber-900/20', text: 'text-amber-700 dark:text-amber-400', dot: 'bg-amber-500' },
  reviewed: { bg: 'bg-blue-100 dark:bg-blue-900/20', text: 'text-blue-700 dark:text-blue-400', dot: 'bg-blue-500' },
  resolved: { bg: 'bg-emerald-100 dark:bg-emerald-900/20', text: 'text-emerald-700 dark:text-emerald-400', dot: 'bg-emerald-500' },
  dismissed: { bg: 'bg-[hsl(var(--muted))]', text: 'text-[hsl(var(--muted-foreground))]', dot: 'bg-slate-400' },
}

export default function ReportsPage() {
  const queryClient = useQueryClient()
  const { page, limit, goToPage, resetPage } = usePagination()

  const [statusFilter, setStatusFilter] = useState('')
  const [typeFilter, setTypeFilter] = useState('')

  const [selectedReport, setSelectedReport] = useState<Report | null>(null)
  const [reviewStatus, setReviewStatus] = useState<string>('resolved')
  const [resolution, setResolution] = useState('')
  const [actionTaken, setActionTaken] = useState<string>('none')

  const { data, isLoading } = useQuery({
    queryKey: ['admin-reports', { status: statusFilter, targetType: typeFilter, page, limit }],
    queryFn: () =>
      adminApi.getReports({
        status: statusFilter || undefined,
        targetType: typeFilter || undefined,
        page,
        limit,
      }),
  })

  const reviewMutation = useMutation({
    mutationFn: ({ id, payload }: { id: string; payload: { status: string; resolution?: string; actionTaken?: string } }) =>
      adminApi.reviewReport(id, payload),
    onSuccess: (result) => {
      toast.success(result.message || 'Report reviewed')
      queryClient.invalidateQueries({ queryKey: ['admin-reports'] })
      queryClient.invalidateQueries({ queryKey: ['dashboard'] })
      setSelectedReport(null)
      setResolution('')
      setActionTaken('none')
    },
    onError: () => toast.error('Failed to review report'),
  })

  /* ─── Helpers ─── */
  const getReporterName = (r: Report) => (typeof r.reporter === 'string' ? 'Unknown' : r.reporter?.name ?? 'Unknown')
  const getReporterEmail = (r: Report) => (typeof r.reporter === 'string' ? '' : r.reporter?.email ?? '')

  const getTargetInfo = (r: Report) => {
    if (!r.target) return 'N/A'
    if (r.targetType === 'user') {
      const t = r.target as Partial<TUser>
      return t.name || t.email || 'Unknown User'
    }
    if (r.targetType === 'listing') {
      const t = r.target as Partial<Listing>
      return t.title || 'Unknown Listing'
    }
    return 'N/A'
  }

  const getListingImage = (r: Report) => {
    if (r.targetType !== 'listing' || !r.target) return null
    const t = r.target as Partial<Listing>
    return t.images?.[0]?.url ?? null
  }

  const getListingPrice = (r: Report) => {
    if (r.targetType !== 'listing' || !r.target) return null
    const t = r.target as Partial<Listing>
    if (t.priceType === 'free') return 'Free'
    if (t.price != null) return `$${t.price}`
    return null
  }

  const getListingDescription = (r: Report) => {
    if (r.targetType !== 'listing' || !r.target) return null
    return (r.target as Partial<Listing>).description ?? null
  }

  const openDetail = (report: Report) => {
    setSelectedReport(report)
    setReviewStatus('resolved')
    setResolution('')
    setActionTaken('none')
  }

  const submitReview = (overrideAction?: string) => {
    if (!selectedReport) return
    reviewMutation.mutate({
      id: selectedReport._id,
      payload: {
        status: overrideAction === 'user_banned' ? 'resolved' : reviewStatus,
        resolution: resolution || undefined,
        actionTaken: overrideAction ?? actionTaken,
      },
    })
  }

  const reports = data?.data ?? []
  const pendingCount = reports.filter((r) => r.status === 'pending').length

  const statusFilters: { label: string; value: string; icon: typeof Shield }[] = [
    { label: 'All Reports', value: '', icon: Shield },
    { label: 'Pending', value: 'pending', icon: Clock },
    { label: 'Reviewed', value: 'reviewed', icon: Eye },
    { label: 'Resolved', value: 'resolved', icon: CheckCircle2 },
    { label: 'Dismissed', value: 'dismissed', icon: XCircle },
  ]

  return (
    <div className="flex flex-col h-[calc(100vh-7rem)] animate-fade-in">
      <div className="flex-1 flex overflow-hidden">

        {/* ══════════════════════════════ LEFT: REPORT LIST ══════════════════════════════ */}
        <div className="flex-1 flex flex-col min-w-0">

          {/* ── Header ── */}
          <div className="px-6 pt-6 pb-5 shrink-0">
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-4">
                <div className="h-12 w-12 rounded-2xl bg-gradient-to-br from-[hsl(var(--primary))] to-teal-700 flex items-center justify-center shadow-lg shadow-[hsl(var(--primary)/0.25)]">
                  <Shield className="h-6 w-6 text-white" />
                </div>
                <div>
                  <h2 className="text-2xl font-bold font-display tracking-tight">Moderation Center</h2>
                  <p className="text-sm text-[hsl(var(--muted-foreground))] mt-0.5">
                    Review and act on reported content across the platform
                  </p>
                </div>
              </div>
              {pendingCount > 0 && (
                <div className="flex items-center gap-2 px-3.5 py-2 rounded-xl bg-amber-500/10 border border-amber-500/20">
                  <div className="h-2 w-2 rounded-full bg-amber-500 animate-pulse" />
                  <span className="text-sm font-semibold text-amber-700 dark:text-amber-400">
                    {pendingCount} awaiting review
                  </span>
                </div>
              )}
            </div>

            {/* ── Filter bar ── */}
            <div className="mt-5 flex items-center gap-2">
              <div className="flex items-center gap-1.5 p-1 rounded-xl bg-[hsl(var(--muted)/0.5)] border border-[hsl(var(--border)/0.5)]">
                {statusFilters.map((f) => {
                  const active = statusFilter === f.value
                  const FilterIcon = f.icon
                  return (
                    <button
                      key={f.value}
                      onClick={() => { setStatusFilter(f.value); resetPage() }}
                      className={`relative px-3.5 py-2 rounded-lg text-[13px] font-medium transition-all duration-200 flex items-center gap-1.5 ${active
                          ? 'bg-[hsl(var(--card))] text-[hsl(var(--foreground))] shadow-sm'
                          : 'text-[hsl(var(--muted-foreground))] hover:text-[hsl(var(--foreground))] hover:bg-[hsl(var(--card)/0.5)]'
                        }`}
                    >
                      <FilterIcon className="h-3.5 w-3.5" />
                      {f.label}
                      {f.value === 'pending' && pendingCount > 0 && (
                        <span className="ml-0.5 bg-amber-500 text-white text-[10px] px-1.5 py-0.5 rounded-full leading-none font-bold min-w-[18px] text-center">
                          {pendingCount}
                        </span>
                      )}
                    </button>
                  )
                })}
              </div>

              <div className="ml-auto">
                <Select
                  value={typeFilter}
                  onChange={(e) => { setTypeFilter(e.target.value); resetPage() }}
                >
                  <option value="">All Types</option>
                  <option value="user">User</option>
                  <option value="listing">Listing</option>
                  <option value="message">Message</option>
                </Select>
              </div>
            </div>
          </div>

          {/* ── Divider ── */}
          <div className="h-px bg-gradient-to-r from-transparent via-[hsl(var(--border))] to-transparent mx-6" />

          {/* ── Report cards ── */}
          <div className="flex-1 overflow-y-auto px-6 pt-4 pb-6">
            {isLoading ? (
              <div className="flex flex-col gap-3 stagger-children">
                {Array.from({ length: 5 }).map((_, i) => (
                  <div key={i} className="rounded-2xl overflow-hidden">
                    <Skeleton className="h-[88px]" />
                  </div>
                ))}
              </div>
            ) : reports.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-24 text-center">
                <div className="h-20 w-20 rounded-3xl bg-[hsl(var(--muted)/0.5)] flex items-center justify-center mb-5">
                  <Shield className="h-10 w-10 text-[hsl(var(--muted-foreground))] opacity-30" />
                </div>
                <h3 className="text-lg font-semibold font-display mb-1.5">All Clear</h3>
                <p className="text-sm text-[hsl(var(--muted-foreground))] max-w-[220px]">
                  No reports match your current filters. Try adjusting them.
                </p>
              </div>
            ) : (
              <div className="flex flex-col gap-2.5 stagger-children">
                {reports.map((report) => {
                  const meta = reasonMeta[report.reason] ?? defaultMeta
                  const Icon = meta.icon
                  const isSelected = selectedReport?._id === report._id
                  const status = statusConfig[report.status] ?? statusConfig.pending
                  const severity = reasonSeverity[report.reason] ?? 'low'
                  const sevInfo = severityLabel[severity]

                  return (
                    <button
                      key={report._id}
                      onClick={() => openDetail(report)}
                      className={`group relative text-left w-full rounded-2xl overflow-hidden flex transition-all duration-200 ${isSelected
                          ? `bg-[hsl(var(--card))] shadow-md ${meta.glowColor} ring-2 ${meta.accentRing} border border-[hsl(var(--primary)/0.3)]`
                          : 'bg-[hsl(var(--card))] shadow-sm border border-[hsl(var(--border)/0.7)] hover:shadow-md hover:border-[hsl(var(--border))] hover:-translate-y-[1px]'
                        }`}
                    >
                      {/* Gradient stripe */}
                      <div className={`absolute left-0 top-0 bottom-0 w-[4px] ${meta.stripeBg} transition-all ${isSelected ? 'w-[5px]' : ''}`} />

                      <div className="flex flex-1 p-4 pl-5 items-center gap-4">
                        {/* Icon with gradient bg */}
                        <div className={`relative h-11 w-11 rounded-xl ${meta.iconBg} ${meta.iconColor} flex items-center justify-center shrink-0 shadow-sm`}>
                          <Icon className="h-[18px] w-[18px]" />
                          {report.status === 'pending' && (
                            <div className="absolute -top-1 -right-1 h-3 w-3 rounded-full bg-amber-500 border-2 border-[hsl(var(--card))] animate-pulse" />
                          )}
                        </div>

                        {/* Info block */}
                        <div className="flex flex-col flex-1 min-w-0 gap-1">
                          <div className="flex items-center gap-2">
                            <h3 className="text-sm font-semibold truncate leading-tight">
                              {capitalize(report.reason.replace(/_/g, ' '))}
                            </h3>
                            <span className={`text-[10px] font-bold uppercase tracking-wider ${sevInfo.color}`}>
                              {sevInfo.label}
                            </span>
                          </div>
                          <div className="flex items-center gap-1.5 text-[13px] text-[hsl(var(--muted-foreground))]">
                            <span className="font-medium text-[hsl(var(--foreground)/0.8)]">
                              {capitalize(report.targetType)}
                            </span>
                            <span className="opacity-40">&middot;</span>
                            <span className="truncate">{getTargetInfo(report)}</span>
                          </div>
                          <div className="flex items-center gap-1.5 text-xs text-[hsl(var(--muted-foreground)/0.7)]">
                            <User className="h-3 w-3" />
                            <span className="font-medium text-[hsl(var(--foreground)/0.6)]">
                              {getReporterName(report)}
                            </span>
                            <span className="opacity-40">&middot;</span>
                            <Clock className="h-3 w-3 opacity-60" />
                            <span>{timeAgo(report.createdAt)}</span>
                          </div>
                        </div>

                        {/* Right side */}
                        <div className="flex flex-col items-end gap-2 shrink-0 ml-2">
                          <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-semibold ${status.bg} ${status.text} border ${status.border}`}>
                            <span className={`h-1.5 w-1.5 rounded-full ${status.dot}`} />
                            {capitalize(report.status)}
                          </span>
                          <ChevronRight className={`h-4 w-4 transition-all duration-200 ${isSelected
                              ? 'text-[hsl(var(--primary))] translate-x-0'
                              : 'text-[hsl(var(--muted-foreground)/0.3)] group-hover:text-[hsl(var(--muted-foreground))] group-hover:translate-x-0.5'
                            }`} />
                        </div>
                      </div>
                    </button>
                  )
                })}

                {data?.pagination && (
                  <div className="mt-3 pt-3 border-t border-[hsl(var(--border)/0.5)]">
                    <Pagination pagination={data.pagination} onPageChange={goToPage} />
                  </div>
                )}
              </div>
            )}
          </div>
        </div>


        {/* ═══════════════ Right: Detail Panel ═══════════════ */}
        {selectedReport && (() => {
          const meta = reasonMeta[selectedReport.reason] ?? defaultMeta
          const Icon = meta.icon
          const thumbUrl = getListingImage(selectedReport)
          const price = getListingPrice(selectedReport)
          const desc = getListingDescription(selectedReport)
          const badge = statusBadge[selectedReport.status] ?? statusBadge.pending

          return (
            <aside className="w-[420px] bg-[hsl(var(--card))] border-l border-[hsl(var(--border))] flex flex-col shrink-0 animate-slide-in-right">

              {/* Panel header */}
              <div className="px-6 py-4 border-b border-[hsl(var(--border))] flex items-center justify-between shrink-0">
                <div>
                  <h2 className="text-base font-semibold font-display">Report Details</h2>
                  <div className="flex items-center gap-2 mt-1">
                    <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-semibold uppercase tracking-wider ${badge.bg} ${badge.text}`}>
                      <span className={`h-1.5 w-1.5 rounded-full ${badge.dot}`} />
                      {capitalize(selectedReport.status)}
                    </span>
                    <span className="text-xs text-[hsl(var(--muted-foreground))]">
                      {timeAgo(selectedReport.createdAt)}
                    </span>
                  </div>
                </div>
                <button
                  onClick={() => setSelectedReport(null)}
                  className="p-1.5 rounded-lg text-[hsl(var(--muted-foreground))] hover:text-[hsl(var(--foreground))] hover:bg-[hsl(var(--muted)/0.5)] transition-colors"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>

              {/* Scrollable content */}
              <div className="flex-1 overflow-y-auto p-6 flex flex-col gap-6">

                {/* Reporter */}
                <section>
                  <h4 className="text-xs font-bold uppercase tracking-wider text-[hsl(var(--muted-foreground))] mb-3">
                    Reported By
                  </h4>
                  <div className="flex items-center gap-3">
                    <div className="h-9 w-9 rounded-full bg-[hsl(var(--primary)/0.1)] flex items-center justify-center text-sm font-bold text-[hsl(var(--primary))]">
                      {getReporterName(selectedReport).charAt(0).toUpperCase()}
                    </div>
                    <div className="flex-1 min-w-0">
                      <span className="text-sm font-medium block truncate">{getReporterName(selectedReport)}</span>
                      {getReporterEmail(selectedReport) && (
                        <span className="text-xs text-[hsl(var(--muted-foreground))] truncate block">{getReporterEmail(selectedReport)}</span>
                      )}
                    </div>
                  </div>
                </section>

                {/* Reported content */}
                <section>
                  <div className="flex items-center justify-between mb-3">
                    <h4 className="text-xs font-bold uppercase tracking-wider text-[hsl(var(--muted-foreground))]">
                      Reported Content
                    </h4>
                    <span className="text-xs text-[hsl(var(--primary))] font-medium cursor-pointer hover:underline flex items-center gap-1">
                      View {capitalize(selectedReport.targetType)}
                      <ExternalLink className="h-3 w-3" />
                    </span>
                  </div>
                  <div className="bg-[hsl(var(--muted)/0.3)] rounded-xl border border-[hsl(var(--border))] overflow-hidden">
                    {thumbUrl && (
                      <div className="h-36 bg-[hsl(var(--muted))]">
                        <img src={thumbUrl} alt="" className="w-full h-full object-cover" />
                      </div>
                    )}
                    <div className="p-4">
                      <h5 className="font-medium text-sm">{getTargetInfo(selectedReport)}</h5>
                      {desc && (
                        <p className="text-xs text-[hsl(var(--muted-foreground))] mt-1 line-clamp-2">{desc}</p>
                      )}
                      {price && <div className="mt-2 font-bold text-sm">{price}</div>}
                    </div>
                  </div>
                </section>

                {/* Reason */}
                <section>
                  <h4 className="text-xs font-bold uppercase tracking-wider text-[hsl(var(--muted-foreground))] mb-3">
                    Reason for Report
                  </h4>
                  <div className={`${meta.reasonBg} border ${meta.reasonBorder} rounded-xl p-4`}>
                    <div className={`flex items-center gap-2 ${meta.reasonText} font-medium text-sm`}>
                      <Icon className="h-4 w-4" />
                      {capitalize(selectedReport.reason.replace(/_/g, ' '))}
                    </div>
                    {selectedReport.description && (
                      <p className={`text-sm ${meta.reasonText} opacity-80 mt-2 italic`}>
                        &ldquo;{selectedReport.description}&rdquo;
                      </p>
                    )}
                  </div>
                </section>

                {/* Previous resolution */}
                {selectedReport.resolution && (
                  <section>
                    <h4 className="text-xs font-bold uppercase tracking-wider text-[hsl(var(--muted-foreground))] mb-3">
                      Previous Resolution
                    </h4>
                    <p className="text-sm text-[hsl(var(--muted-foreground))] bg-[hsl(var(--muted)/0.3)] rounded-xl p-4 border border-[hsl(var(--border))]">
                      {selectedReport.resolution}
                    </p>
                  </section>
                )}

                {/* Admin actions (only for pending) */}
                {selectedReport.status === 'pending' && (
                  <section>
                    <h4 className="text-xs font-bold uppercase tracking-wider text-[hsl(var(--muted-foreground))] mb-3">
                      Admin Notes
                    </h4>
                    <div className="flex flex-col gap-3">
                      <Textarea
                        className="text-sm rounded-xl resize-none"
                        placeholder="Add internal notes about this report..."
                        value={resolution}
                        onChange={(e) => setResolution(e.target.value)}
                        rows={3}
                      />
                      <div className="flex gap-3">
                        <div className="flex-1 space-y-1.5">
                          <label className="text-xs font-medium text-[hsl(var(--muted-foreground))]">Status</label>
                          <Select value={reviewStatus} onChange={(e) => setReviewStatus(e.target.value)}>
                            <option value="reviewed">Reviewed</option>
                            <option value="resolved">Resolved</option>
                            <option value="dismissed">Dismissed</option>
                          </Select>
                        </div>
                        <div className="flex-1 space-y-1.5">
                          <label className="text-xs font-medium text-[hsl(var(--muted-foreground))]">Action</label>
                          <Select value={actionTaken} onChange={(e) => setActionTaken(e.target.value)}>
                            <option value="none">No Action</option>
                            <option value="warning">Send Warning</option>
                            <option value="content_removed">Remove Content</option>
                            <option value="user_banned">Ban User</option>
                          </Select>
                        </div>
                      </div>
                    </div>
                  </section>
                )}
              </div>

              {/* Sticky action footer */}
              {selectedReport.status === 'pending' && (
                <div className="p-5 border-t border-[hsl(var(--border))] shrink-0 flex flex-col gap-3">
                  <div className="grid grid-cols-4 gap-2">
                    <button
                      onClick={() => { setActionTaken('warning'); submitReview('warning') }}
                      disabled={reviewMutation.isPending}
                      className="flex flex-col items-center gap-1.5 py-2.5 rounded-xl text-amber-600 dark:text-amber-400 bg-amber-100 dark:bg-amber-900/20 hover:bg-amber-200 dark:hover:bg-amber-900/30 transition-colors active:scale-[0.98] disabled:opacity-40 text-[10px] font-semibold"
                    >
                      <AlertTriangle className="h-4 w-4" />
                      Warn
                    </button>
                    <button
                      onClick={() => { setActionTaken('content_removed'); submitReview('content_removed') }}
                      disabled={reviewMutation.isPending}
                      className="flex flex-col items-center gap-1.5 py-2.5 rounded-xl text-rose-600 dark:text-rose-400 bg-rose-100 dark:bg-rose-900/20 hover:bg-rose-200 dark:hover:bg-rose-900/30 transition-colors active:scale-[0.98] disabled:opacity-40 text-[10px] font-semibold"
                    >
                      <Trash2 className="h-4 w-4" />
                      Remove
                    </button>
                    <button
                      onClick={() => { setReviewStatus('dismissed'); submitReview() }}
                      disabled={reviewMutation.isPending}
                      className="flex flex-col items-center gap-1.5 py-2.5 rounded-xl text-[hsl(var(--muted-foreground))] bg-[hsl(var(--muted))] hover:bg-[hsl(var(--muted)/0.7)] transition-colors active:scale-[0.98] disabled:opacity-40 text-[10px] font-semibold"
                    >
                      <XCircle className="h-4 w-4" />
                      Dismiss
                    </button>
                    <button
                      onClick={() => submitReview('user_banned')}
                      disabled={reviewMutation.isPending}
                      className="flex flex-col items-center gap-1.5 py-2.5 rounded-xl text-white bg-rose-600 hover:bg-rose-700 transition-colors active:scale-[0.98] shadow-sm disabled:opacity-40 text-[10px] font-semibold"
                    >
                      <Ban className="h-4 w-4" />
                      Ban
                    </button>
                  </div>
                  <Button
                    className="rounded-xl w-full"
                    onClick={() => submitReview()}
                    disabled={reviewMutation.isPending}
                  >
                    <Send className="h-4 w-4 mr-2" />
                    {reviewMutation.isPending ? 'Submitting...' : 'Submit Review'}
                  </Button>
                </div>
              )}
            </aside>
          )
        })()}
      </div>
    </div>
  )
}
