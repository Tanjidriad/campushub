import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '@/api/admin'
import { useDebounce } from '@/hooks/useDebounce'
import { usePagination } from '@/hooks/usePagination'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select } from '@/components/ui/select'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import { Pagination } from '@/components/ui/pagination'
import { Dialog, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from '@/components/ui/dialog'
import { Skeleton } from '@/components/ui/skeleton'
import { toast } from 'sonner'
import { Search, Check, X, Trash2, Star, Eye, BookOpen, Clock, CheckCircle, XCircle } from 'lucide-react'
import { formatDate, formatCurrency, capitalize } from '@/lib/utils'
import type { Listing, ListingStatus } from '@/types'

const statusColors: Record<ListingStatus, 'default' | 'success' | 'destructive' | 'warning' | 'secondary'> = {
  pending: 'warning',
  approved: 'success',
  rejected: 'destructive',
  sold: 'default',
  expired: 'secondary',
  hidden: 'secondary',
  removed: 'destructive',
}

interface ListingsPageProps {
  pendingOnly?: boolean
}

export default function ListingsPage({ pendingOnly = false }: ListingsPageProps) {
  const queryClient = useQueryClient()
  const { page, limit, goToPage, resetPage } = usePagination()

  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState(pendingOnly ? 'pending' : '')
  const [categoryFilter, setCategoryFilter] = useState('')
  const [conditionFilter, setConditionFilter] = useState('')
  const debouncedSearch = useDebounce(search)

  // Selected for bulk actions
  const [selectedIds, setSelectedIds] = useState<string[]>([])

  // Dialogs
  const [rejectDialog, setRejectDialog] = useState<{ open: boolean; id: string; title: string }>({
    open: false, id: '', title: '',
  })
  const [rejectReason, setRejectReason] = useState('')
  const [deleteDialog, setDeleteDialog] = useState<{ open: boolean; id: string; title: string }>({
    open: false, id: '', title: '',
  })
  const [detailDialog, setDetailDialog] = useState<{ open: boolean; listing: Listing | null }>({
    open: false, listing: null,
  })
  const [bulkRejectDialog, setBulkRejectDialog] = useState(false)
  const [bulkRejectReason, setBulkRejectReason] = useState('')
  const [bulkDeleteDialog, setBulkDeleteDialog] = useState(false)

  const queryKey = pendingOnly
    ? ['admin-listings-pending', { page, limit }]
    : ['admin-listings', { search: debouncedSearch, status: statusFilter, category: categoryFilter, condition: conditionFilter, page, limit }]

  const { data, isLoading } = useQuery({
    queryKey,
    queryFn: () =>
      pendingOnly
        ? adminApi.getPendingListings({ page, limit })
        : adminApi.getListings({
            search: debouncedSearch || undefined,
            status: statusFilter || undefined,
            category: categoryFilter || undefined,
            condition: conditionFilter || undefined,
            page,
            limit,
          }),
  })

  const approveMutation = useMutation({
    mutationFn: (id: string) => adminApi.approveListing(id),
    onSuccess: () => {
      toast.success('Listing approved')
      queryClient.invalidateQueries({ queryKey: ['admin-listings'] })
      queryClient.invalidateQueries({ queryKey: ['admin-listings-pending'] })
      queryClient.invalidateQueries({ queryKey: ['dashboard'] })
    },
    onError: () => toast.error('Failed to approve listing'),
  })

  const rejectMutation = useMutation({
    mutationFn: ({ id, reason }: { id: string; reason: string }) => adminApi.rejectListing(id, reason),
    onSuccess: () => {
      toast.success('Listing rejected')
      queryClient.invalidateQueries({ queryKey: ['admin-listings'] })
      queryClient.invalidateQueries({ queryKey: ['admin-listings-pending'] })
      setRejectDialog({ open: false, id: '', title: '' })
      setRejectReason('')
    },
    onError: () => toast.error('Failed to reject listing'),
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => adminApi.deleteListing(id),
    onSuccess: () => {
      toast.success('Listing deleted')
      queryClient.invalidateQueries({ queryKey: ['admin-listings'] })
      queryClient.invalidateQueries({ queryKey: ['admin-listings-pending'] })
      setDeleteDialog({ open: false, id: '', title: '' })
    },
    onError: () => toast.error('Failed to delete listing'),
  })

  const featureMutation = useMutation({
    mutationFn: (id: string) => adminApi.toggleFeature(id),
    onSuccess: (result) => {
      toast.success(result.data?.isFeatured ? 'Listing featured' : 'Listing unfeatured')
      queryClient.invalidateQueries({ queryKey: ['admin-listings'] })
    },
    onError: () => toast.error('Failed to toggle feature'),
  })

  const bulkApproveMutation = useMutation({
    mutationFn: (ids: string[]) => adminApi.bulkApprove(ids),
    onSuccess: (result) => {
      toast.success(`${result.data?.count} listing(s) approved`)
      setSelectedIds([])
      queryClient.invalidateQueries({ queryKey: ['admin-listings'] })
      queryClient.invalidateQueries({ queryKey: ['admin-listings-pending'] })
    },
    onError: () => toast.error('Bulk approve failed'),
  })

  const bulkRejectMutation = useMutation({
    mutationFn: ({ ids, reason }: { ids: string[]; reason: string }) => adminApi.bulkReject(ids, reason),
    onSuccess: (result) => {
      toast.success(`${result.data?.count} listing(s) rejected`)
      setSelectedIds([])
      setBulkRejectDialog(false)
      setBulkRejectReason('')
      queryClient.invalidateQueries({ queryKey: ['admin-listings'] })
      queryClient.invalidateQueries({ queryKey: ['admin-listings-pending'] })
    },
    onError: () => toast.error('Bulk reject failed'),
  })

  const bulkDeleteMutation = useMutation({
    mutationFn: (ids: string[]) => adminApi.bulkDelete(ids),
    onSuccess: (result) => {
      toast.success(`${result.data?.count} listing(s) deleted`)
      setSelectedIds([])
      setBulkDeleteDialog(false)
      queryClient.invalidateQueries({ queryKey: ['admin-listings'] })
      queryClient.invalidateQueries({ queryKey: ['admin-listings-pending'] })
    },
    onError: () => toast.error('Bulk delete failed'),
  })

  const listings = data?.data ?? []
  const stats = (data as { statistics?: Record<string, number> })?.statistics

  const toggleSelect = (id: string) => {
    setSelectedIds((prev) => (prev.includes(id) ? prev.filter((i) => i !== id) : [...prev, id]))
  }

  const toggleSelectAll = () => {
    if (selectedIds.length === listings.length) {
      setSelectedIds([])
    } else {
      setSelectedIds(listings.map((l) => l._id))
    }
  }

  const getSellerName = (listing: Listing) => {
    if (typeof listing.seller === 'string') return 'Unknown'
    return listing.seller?.name ?? 'Unknown'
  }

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold font-display">{pendingOnly ? 'Pending Listings' : 'Listings'}</h2>
          <p className="text-sm text-[hsl(var(--muted-foreground))] mt-1">Manage all marketplace listings.</p>
        </div>
      </div>

      {/* Quick Stats */}
      {!pendingOnly && stats && (
        <div className="flex flex-wrap gap-4">
          {[
            { label: 'Total', value: stats.total ?? 0, icon: BookOpen, color: '#0D9488', bg: 'bg-[#0D9488]/10' },
            { label: 'Pending', value: stats.pending ?? 0, icon: Clock, color: '#F59E0B', bg: 'bg-[#F59E0B]/10' },
            { label: 'Approved', value: stats.approved ?? 0, icon: CheckCircle, color: '#10B981', bg: 'bg-emerald-500/10' },
            { label: 'Rejected', value: stats.rejected ?? 0, icon: XCircle, color: '#EF4444', bg: 'bg-rose-500/10' },
          ].map((s) => (
            <div key={s.label} className="flex items-center gap-3 bg-[hsl(var(--card))] px-4 py-3 rounded-xl border border-[hsl(var(--border))] shadow-sm flex-1 min-w-[180px]">
              <div className={`h-10 w-10 rounded-full ${s.bg} flex items-center justify-center shrink-0`}>
                <s.icon className="h-5 w-5" style={{ color: s.color }} />
              </div>
              <div>
                <p className="text-sm font-medium text-[hsl(var(--muted-foreground))]">{s.label}</p>
                <p className="text-xl font-bold font-display">{Number(s.value).toLocaleString()}</p>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Search & Filters */}
      {!pendingOnly && (
        <div className="bg-[hsl(var(--card))] p-4 rounded-xl border border-[hsl(var(--border))] shadow-sm flex flex-wrap gap-4 items-center">
          <div className="flex-1 min-w-[250px] relative">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[hsl(var(--muted-foreground))]" />
            <Input
              placeholder="Search listings..."
              value={search}
              onChange={(e) => { setSearch(e.target.value); resetPage() }}
              className="pl-10"
            />
          </div>
          <div className="flex items-center gap-3">
            <Select value={statusFilter} onChange={(e) => { setStatusFilter(e.target.value); resetPage() }}>
              <option value="">All Status</option>
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="rejected">Rejected</option>
              <option value="sold">Sold</option>
              <option value="expired">Expired</option>
              <option value="removed">Removed</option>
            </Select>
            <Select value={conditionFilter} onChange={(e) => { setConditionFilter(e.target.value); resetPage() }}>
              <option value="">All Conditions</option>
              <option value="new">New</option>
              <option value="like-new">Like New</option>
              <option value="good">Good</option>
              <option value="fair">Fair</option>
              <option value="poor">Poor</option>
            </Select>
          </div>
        </div>
      )}

      {/* Bulk Actions Bar */}
      {selectedIds.length > 0 && (
        <div className="animate-fade-in bg-[hsl(var(--primary)/0.05)] p-4 rounded-xl border border-[hsl(var(--primary)/0.3)] shadow-sm">
          <div className="flex items-center gap-3">
            <span className="text-sm font-medium">{selectedIds.length} selected</span>
            <Button
              size="sm"
              onClick={() => bulkApproveMutation.mutate(selectedIds)}
              disabled={bulkApproveMutation.isPending}
            >
              <Check className="mr-1 h-4 w-4" />
              Approve All
            </Button>
            <Button
              size="sm"
              variant="outline"
              onClick={() => setBulkRejectDialog(true)}
            >
              <X className="mr-1 h-4 w-4" />
              Reject All
            </Button>
            <Button
              size="sm"
              variant="destructive"
              onClick={() => setBulkDeleteDialog(true)}
            >
              <Trash2 className="mr-1 h-4 w-4" />
              Delete All
            </Button>
            <Button size="sm" variant="ghost" onClick={() => setSelectedIds([])}>
              Clear
            </Button>
          </div>
        </div>
      )}

      {/* Listings Table */}
      <div className="bg-[hsl(var(--card))] rounded-xl border border-[hsl(var(--border))] shadow-sm overflow-hidden">
          {isLoading ? (
            <div className="space-y-4 p-6">
              {Array.from({ length: 5 }).map((_, i) => (
                <Skeleton key={i} className="h-16" />
              ))}
            </div>
          ) : (
            <>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="w-12">
                      <input
                        type="checkbox"
                        checked={selectedIds.length === listings.length && listings.length > 0}
                        onChange={toggleSelectAll}
                        className="rounded"
                      />
                    </TableHead>
                    <TableHead>Listing</TableHead>
                    <TableHead>Seller</TableHead>
                    <TableHead>Category</TableHead>
                    <TableHead>Price</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Condition</TableHead>
                    <TableHead>Date</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {listings.map((listing) => (
                    <TableRow key={listing._id}>
                      <TableCell>
                        <input
                          type="checkbox"
                          checked={selectedIds.includes(listing._id)}
                          onChange={() => toggleSelect(listing._id)}
                          className="rounded"
                        />
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          {listing.images[0] && (
                            <img
                              src={listing.images[0].url}
                              alt={listing.title}
                              className="h-10 w-10 rounded-lg object-cover"
                            />
                          )}
                          <div className="max-w-[200px]">
                            <p className="truncate font-medium">{listing.title}</p>
                            {listing.isFeatured && (
                              <span className="mt-1 inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-semibold bg-amber-100 text-amber-700 dark:bg-amber-900/20 dark:text-amber-400">Featured</span>
                            )}
                          </div>
                        </div>
                      </TableCell>
                      <TableCell className="text-sm">{getSellerName(listing)}</TableCell>
                      <TableCell className="text-sm">{listing.category}</TableCell>
                      <TableCell className="text-sm">
                        {listing.priceType === 'free' ? 'Free' : formatCurrency(listing.price, listing.currency)}
                      </TableCell>
                      <TableCell>
                        <span className={`inline-flex items-center gap-1 px-2 py-1 rounded-md text-xs font-medium ${
                          listing.status === 'pending' ? 'bg-amber-100 text-amber-700 dark:bg-amber-900/20 dark:text-amber-400' :
                          listing.status === 'approved' ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/20 dark:text-emerald-400' :
                          listing.status === 'rejected' ? 'bg-rose-100 text-rose-700 dark:bg-rose-900/20 dark:text-rose-400' :
                          listing.status === 'sold' ? 'bg-blue-100 text-blue-700 dark:bg-blue-900/20 dark:text-blue-400' :
                          'bg-[hsl(var(--muted))] text-[hsl(var(--muted-foreground))]'
                        }`}>
                          <span className={`h-1.5 w-1.5 rounded-full ${
                            listing.status === 'pending' ? 'bg-amber-500' :
                            listing.status === 'approved' ? 'bg-emerald-500' :
                            listing.status === 'rejected' ? 'bg-rose-500' :
                            listing.status === 'sold' ? 'bg-blue-500' :
                            'bg-slate-400'
                          }`} />
                          {capitalize(listing.status)}
                        </span>
                      </TableCell>
                      <TableCell className="text-sm">{capitalize(listing.condition)}</TableCell>
                      <TableCell className="text-sm">{formatDate(listing.createdAt)}</TableCell>
                      <TableCell>
                        <div className="flex items-center gap-1">
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => setDetailDialog({ open: true, listing })}
                            title="View"
                          >
                            <Eye className="h-4 w-4" />
                          </Button>
                          {listing.status === 'pending' && (
                            <>
                              <Button
                                variant="ghost"
                                size="icon"
                                onClick={() => approveMutation.mutate(listing._id)}
                                title="Approve"
                              >
                                <Check className="h-4 w-4 text-green-600" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="icon"
                                onClick={() => setRejectDialog({ open: true, id: listing._id, title: listing.title })}
                                title="Reject"
                              >
                                <X className="h-4 w-4 text-red-600" />
                              </Button>
                            </>
                          )}
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => featureMutation.mutate(listing._id)}
                            title={listing.isFeatured ? 'Unfeature' : 'Feature'}
                          >
                            <Star className={`h-4 w-4 ${listing.isFeatured ? 'fill-yellow-500 text-yellow-500' : ''}`} />
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => setDeleteDialog({ open: true, id: listing._id, title: listing.title })}
                            title="Delete"
                          >
                            <Trash2 className="h-4 w-4 text-red-600" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                  {listings.length === 0 && (
                    <TableRow>
                      <TableCell colSpan={9} className="text-center py-12 text-[hsl(var(--muted-foreground))]">
                        <BookOpen className="mx-auto mb-3 h-10 w-10 opacity-30" />
                        <p>{pendingOnly ? 'No pending listings' : 'No listings found'}</p>
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
              {data?.pagination && (
                <Pagination pagination={data.pagination} onPageChange={goToPage} />
              )}
            </>
          )}
      </div>

      {/* Reject Dialog */}
      <Dialog open={rejectDialog.open} onClose={() => setRejectDialog({ ...rejectDialog, open: false })}>
        <DialogHeader>
          <DialogTitle>Reject Listing</DialogTitle>
          <DialogDescription>Provide a reason for rejecting "{rejectDialog.title}"</DialogDescription>
        </DialogHeader>
        <Textarea
          placeholder="Enter rejection reason..."
          value={rejectReason}
          onChange={(e) => setRejectReason(e.target.value)}
          rows={3}
        />
        <DialogFooter>
          <Button variant="outline" onClick={() => setRejectDialog({ ...rejectDialog, open: false })}>
            Cancel
          </Button>
          <Button
            variant="destructive"
            onClick={() => rejectMutation.mutate({ id: rejectDialog.id, reason: rejectReason })}
            disabled={!rejectReason.trim() || rejectMutation.isPending}
          >
            {rejectMutation.isPending ? 'Rejecting...' : 'Reject Listing'}
          </Button>
        </DialogFooter>
      </Dialog>

      {/* Delete Dialog */}
      <Dialog open={deleteDialog.open} onClose={() => setDeleteDialog({ ...deleteDialog, open: false })}>
        <DialogHeader>
          <DialogTitle>Delete Listing</DialogTitle>
          <DialogDescription>
            Permanently delete "{deleteDialog.title}"? Images will also be removed.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" onClick={() => setDeleteDialog({ ...deleteDialog, open: false })}>
            Cancel
          </Button>
          <Button
            variant="destructive"
            onClick={() => deleteMutation.mutate(deleteDialog.id)}
            disabled={deleteMutation.isPending}
          >
            {deleteMutation.isPending ? 'Deleting...' : 'Delete'}
          </Button>
        </DialogFooter>
      </Dialog>

      {/* Detail Dialog */}
      <Dialog
        open={detailDialog.open}
        onClose={() => setDetailDialog({ open: false, listing: null })}
        className="max-w-2xl"
      >
        {detailDialog.listing && (
          <>
            <DialogHeader>
              <DialogTitle>{detailDialog.listing.title}</DialogTitle>
            </DialogHeader>
            <div className="space-y-4">
              {/* Images */}
              {detailDialog.listing.images.length > 0 && (
                <div className="flex gap-2 overflow-x-auto pb-2">
                  {detailDialog.listing.images.map((img, i) => (
                    <img
                      key={i}
                      src={img.url}
                      alt={`${detailDialog.listing!.title} ${i + 1}`}
                      className="h-40 w-40 rounded-xl object-cover flex-shrink-0 transition-transform hover:scale-105"
                    />
                  ))}
                </div>
              )}
              <div className="grid gap-3 text-sm md:grid-cols-2">
                <div><strong>Status:</strong> <Badge variant={statusColors[detailDialog.listing.status]}>{capitalize(detailDialog.listing.status)}</Badge></div>
                <div><strong>Price:</strong> {detailDialog.listing.priceType === 'free' ? 'Free' : formatCurrency(detailDialog.listing.price, detailDialog.listing.currency)}</div>
                <div><strong>Condition:</strong> {capitalize(detailDialog.listing.condition)}</div>
                <div><strong>Category:</strong> {detailDialog.listing.category}</div>
                <div><strong>Seller:</strong> {getSellerName(detailDialog.listing)}</div>
                <div><strong>Views:</strong> {detailDialog.listing.views}</div>
                {detailDialog.listing.educationLevel && <div><strong>Education:</strong> {detailDialog.listing.educationLevel}</div>}
                {detailDialog.listing.subject && <div><strong>Subject:</strong> {detailDialog.listing.subject}</div>}
                {detailDialog.listing.rejectionReason && <div className="md:col-span-2"><strong>Rejection Reason:</strong> {detailDialog.listing.rejectionReason}</div>}
              </div>
              <div>
                <strong className="text-sm">Description:</strong>
                <p className="mt-1 text-sm text-[hsl(var(--muted-foreground))] whitespace-pre-wrap">{detailDialog.listing.description}</p>
              </div>
            </div>
          </>
        )}
      </Dialog>

      {/* Bulk Reject Dialog */}
      <Dialog open={bulkRejectDialog} onClose={() => setBulkRejectDialog(false)}>
        <DialogHeader>
          <DialogTitle>Bulk Reject</DialogTitle>
          <DialogDescription>Reject {selectedIds.length} selected listing(s)</DialogDescription>
        </DialogHeader>
        <Textarea
          placeholder="Enter rejection reason..."
          value={bulkRejectReason}
          onChange={(e) => setBulkRejectReason(e.target.value)}
          rows={3}
        />
        <DialogFooter>
          <Button variant="outline" onClick={() => setBulkRejectDialog(false)}>Cancel</Button>
          <Button
            variant="destructive"
            onClick={() => bulkRejectMutation.mutate({ ids: selectedIds, reason: bulkRejectReason })}
            disabled={!bulkRejectReason.trim() || bulkRejectMutation.isPending}
          >
            {bulkRejectMutation.isPending ? 'Rejecting...' : 'Reject All'}
          </Button>
        </DialogFooter>
      </Dialog>

      {/* Bulk Delete Dialog */}
      <Dialog open={bulkDeleteDialog} onClose={() => setBulkDeleteDialog(false)}>
        <DialogHeader>
          <DialogTitle>Bulk Delete</DialogTitle>
          <DialogDescription>
            Permanently delete {selectedIds.length} listing(s)? This cannot be undone.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" onClick={() => setBulkDeleteDialog(false)}>Cancel</Button>
          <Button
            variant="destructive"
            onClick={() => bulkDeleteMutation.mutate(selectedIds)}
            disabled={bulkDeleteMutation.isPending}
          >
            {bulkDeleteMutation.isPending ? 'Deleting...' : 'Delete All'}
          </Button>
        </DialogFooter>
      </Dialog>
    </div>
  )
}
