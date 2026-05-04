import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useNavigate } from 'react-router-dom'
import { adminApi } from '@/api/admin'
import { useAuth } from '@/context/AuthContext'
import { useDebounce } from '@/hooks/useDebounce'
import { usePagination } from '@/hooks/usePagination'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select } from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import { Pagination } from '@/components/ui/pagination'
import { Dialog, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Skeleton } from '@/components/ui/skeleton'
import { toast } from 'sonner'
import { Search, Ban, ShieldCheck, UserCog, Eye, Users, UserX, ShieldAlert } from 'lucide-react'
import { formatDate } from '@/lib/utils'

export default function UsersPage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { user: currentUser } = useAuth()
  const { page, limit, goToPage, resetPage } = usePagination()

  const [search, setSearch] = useState('')
  const [roleFilter, setRoleFilter] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const debouncedSearch = useDebounce(search)

  // Ban/unban dialog
  const [banDialog, setBanDialog] = useState<{ open: boolean; userId: string; userName: string; isBanned: boolean }>({
    open: false, userId: '', userName: '', isBanned: false,
  })

  // Role change dialog
  const [roleDialog, setRoleDialog] = useState<{ open: boolean; userId: string; userName: string; currentRole: string; newRole: string }>({
    open: false, userId: '', userName: '', currentRole: '', newRole: '',
  })

  const { data, isLoading } = useQuery({
    queryKey: ['admin-users', { search: debouncedSearch, role: roleFilter, status: statusFilter, page, limit }],
    queryFn: () =>
      adminApi.getUsers({
        search: debouncedSearch || undefined,
        role: roleFilter || undefined,
        status: statusFilter || undefined,
        page,
        limit,
      }),
  })

  const banMutation = useMutation({
    mutationFn: (id: string) => adminApi.toggleBan(id),
    onSuccess: (result) => {
      toast.success(result.message)
      queryClient.invalidateQueries({ queryKey: ['admin-users'] })
      setBanDialog({ open: false, userId: '', userName: '', isBanned: false })
    },
    onError: () => toast.error('Failed to update user status'),
  })

  const roleMutation = useMutation({
    mutationFn: ({ id, role }: { id: string; role: string }) => adminApi.changeRole(id, role),
    onSuccess: () => {
      toast.success('Role updated successfully')
      queryClient.invalidateQueries({ queryKey: ['admin-users'] })
      setRoleDialog({ open: false, userId: '', userName: '', currentRole: '', newRole: '' })
    },
    onError: () => toast.error('Failed to change role'),
  })

  const stats = data?.statistics

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold font-display">Users</h2>
          <p className="text-sm text-[hsl(var(--muted-foreground))] mt-1">Manage all registered users on CampusHub.</p>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="flex flex-wrap gap-4">
        {[
          { label: 'Total Users', value: stats?.total ?? 0, icon: Users, color: '#0D9488', bg: 'bg-[#0D9488]/10' },
          { label: 'Active', value: stats?.active ?? 0, icon: ShieldCheck, color: '#10B981', bg: 'bg-emerald-500/10' },
          { label: 'Banned', value: stats?.banned ?? 0, icon: UserX, color: '#EF4444', bg: 'bg-rose-500/10' },
          { label: 'Admins', value: stats?.admins ?? 0, icon: ShieldAlert, color: '#8B5CF6', bg: 'bg-violet-500/10' },
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

      {/* Search & Filters */}
      <div className="bg-[hsl(var(--card))] p-4 rounded-xl border border-[hsl(var(--border))] shadow-sm flex flex-wrap gap-4 items-center">
        <div className="flex-1 min-w-[250px] relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[hsl(var(--muted-foreground))]" />
          <Input
            placeholder="Search name, email, or ID..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); resetPage() }}
            className="pl-10"
          />
        </div>
        <div className="flex items-center gap-3">
          <Select value={roleFilter} onChange={(e) => { setRoleFilter(e.target.value); resetPage() }}>
            <option value="">All Roles</option>
            <option value="student">Student</option>
            <option value="admin">Admin</option>
            <option value="superadmin">Super Admin</option>
          </Select>
          <Select value={statusFilter} onChange={(e) => { setStatusFilter(e.target.value); resetPage() }}>
            <option value="">All Status</option>
            <option value="active">Active</option>
            <option value="banned">Banned</option>
          </Select>
        </div>
      </div>

      {/* Users Table */}
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
                  <TableHead>User</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Listings</TableHead>
                  <TableHead>Joined</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {data?.data.map((user) => (
                  <TableRow key={user._id} className="group hover:bg-[hsl(var(--muted)/0.3)] transition-colors">
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="relative">
                          <Avatar className="h-9 w-9">
                            <AvatarImage src={user.avatar} alt={user.name} />
                            <AvatarFallback className="text-sm font-medium">{user.name.charAt(0).toUpperCase()}</AvatarFallback>
                          </Avatar>
                          <span className={`absolute bottom-0 right-0 h-2.5 w-2.5 rounded-full border-2 border-[hsl(var(--card))] ${user.isOnline ? 'bg-emerald-500' : 'bg-slate-300 dark:bg-slate-600'}`} />
                        </div>
                        <div>
                          <p className="font-medium text-sm">{user.name}</p>
                          <p className="text-xs text-[hsl(var(--muted-foreground))]">{user.email}</p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className={`inline-flex items-center px-2 py-1 rounded-md text-xs font-medium ${user.role === 'superadmin'
                          ? 'bg-amber-100 text-amber-700 dark:bg-amber-900/20 dark:text-amber-400 border border-amber-200/50'
                          : user.role === 'admin'
                            ? 'bg-[hsl(var(--primary)/0.1)] text-[hsl(var(--primary))] border border-[hsl(var(--primary)/0.2)]'
                            : 'bg-[hsl(var(--muted))] text-[hsl(var(--muted-foreground))]'
                        }`}>
                        {user.role}
                      </span>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1.5">
                        <span className={`h-1.5 w-1.5 rounded-full ${user.isBlocked ? 'bg-rose-500' : 'bg-emerald-500'}`} />
                        <span className="text-sm">{user.isBlocked ? 'Banned' : 'Active'}</span>
                      </div>
                    </TableCell>
                    <TableCell className="text-sm">{user.totalListings}</TableCell>
                    <TableCell className="text-sm text-[hsl(var(--muted-foreground))]">{formatDate(user.createdAt)}</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => navigate(`/users/${user._id}`)}
                          title="View details"
                        >
                          <Eye className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() =>
                            setBanDialog({
                              open: true,
                              userId: user._id,
                              userName: user.name,
                              isBanned: user.isBlocked,
                            })
                          }
                          title={user.isBlocked ? 'Unban' : 'Ban'}
                        >
                          <Ban className={`h-4 w-4 ${user.isBlocked ? 'text-green-600' : 'text-red-600'}`} />
                        </Button>
                        {currentUser?.role === 'superadmin' && (
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() =>
                              setRoleDialog({
                                open: true,
                                userId: user._id,
                                userName: user.name,
                                currentRole: user.role,
                                newRole: user.role,
                              })
                            }
                            title="Change role"
                          >
                            <UserCog className="h-4 w-4" />
                          </Button>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
                {data?.data.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center py-12 text-[hsl(var(--muted-foreground))]">
                      <Users className="mx-auto mb-3 h-10 w-10 opacity-30" />
                      <p>No users found</p>
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

      {/* Ban/Unban Dialog */}
      <Dialog open={banDialog.open} onClose={() => setBanDialog({ ...banDialog, open: false })}>
        <DialogHeader>
          <DialogTitle>
            {banDialog.isBanned ? 'Unban' : 'Ban'} User
          </DialogTitle>
        </DialogHeader>
        <p className="text-sm text-[hsl(var(--muted-foreground))]">
          Are you sure you want to {banDialog.isBanned ? 'unban' : 'ban'}{' '}
          <strong>{banDialog.userName}</strong>?
          {!banDialog.isBanned && ' All their listings will be removed.'}
          {banDialog.isBanned && ' Their previously removed listings will be restored.'}
        </p>
        <DialogFooter>
          <Button variant="outline" onClick={() => setBanDialog({ ...banDialog, open: false })}>
            Cancel
          </Button>
          <Button
            variant={banDialog.isBanned ? 'default' : 'destructive'}
            onClick={() => banMutation.mutate(banDialog.userId)}
            disabled={banMutation.isPending}
          >
            {banMutation.isPending ? 'Processing...' : banDialog.isBanned ? 'Unban User' : 'Ban User'}
          </Button>
        </DialogFooter>
      </Dialog>

      {/* Role Change Dialog */}
      <Dialog open={roleDialog.open} onClose={() => setRoleDialog({ ...roleDialog, open: false })}>
        <DialogHeader>
          <DialogTitle>Change Role</DialogTitle>
        </DialogHeader>
        <p className="mb-4 text-sm text-[hsl(var(--muted-foreground))]">
          Change role for <strong>{roleDialog.userName}</strong>
        </p>
        <Select
          value={roleDialog.newRole}
          onChange={(e) => setRoleDialog({ ...roleDialog, newRole: e.target.value })}
        >
          <option value="student">Student</option>
          <option value="admin">Admin</option>
          <option value="superadmin">Super Admin</option>
        </Select>
        <DialogFooter>
          <Button variant="outline" onClick={() => setRoleDialog({ ...roleDialog, open: false })}>
            Cancel
          </Button>
          <Button
            onClick={() => roleMutation.mutate({ id: roleDialog.userId, role: roleDialog.newRole })}
            disabled={roleMutation.isPending || roleDialog.newRole === roleDialog.currentRole}
          >
            {roleMutation.isPending ? 'Saving...' : 'Update Role'}
          </Button>
        </DialogFooter>
      </Dialog>
    </div>
  )
}
