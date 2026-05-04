import { useParams, useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '@/api/admin'
import { useAuth } from '@/context/AuthContext'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar'
import { Skeleton } from '@/components/ui/skeleton'
import { toast } from 'sonner'
import { ArrowLeft, Ban, Mail, Phone, MapPin, Calendar, BookOpen, Star } from 'lucide-react'
import { formatDate } from '@/lib/utils'

export default function UserDetailPage() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { user: currentUser } = useAuth()

  const { data: user, isLoading } = useQuery({
    queryKey: ['admin-user', id],
    queryFn: () => adminApi.getUser(id!),
    enabled: !!id,
  })

  const banMutation = useMutation({
    mutationFn: () => adminApi.toggleBan(id!),
    onSuccess: (result) => {
      toast.success(result.message)
      queryClient.invalidateQueries({ queryKey: ['admin-user', id] })
      queryClient.invalidateQueries({ queryKey: ['admin-users'] })
    },
    onError: () => toast.error('Action failed'),
  })

  const roleMutation = useMutation({
    mutationFn: (role: string) => adminApi.changeRole(id!, role),
    onSuccess: () => {
      toast.success('Role updated')
      queryClient.invalidateQueries({ queryKey: ['admin-user', id] })
    },
    onError: () => toast.error('Failed to update role'),
  })

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-10 w-32" />
        <Skeleton className="h-64" />
      </div>
    )
  }

  if (!user) {
    return (
      <div className="text-center py-12">
        <p className="text-lg text-[hsl(var(--muted-foreground))]">User not found</p>
        <Button variant="outline" className="mt-4" onClick={() => navigate('/users')}>
          Back to Users
        </Button>
      </div>
    )
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <Button variant="ghost" onClick={() => navigate('/users')}>
        <ArrowLeft className="mr-2 h-4 w-4" />
        Back to Users
      </Button>

      <div className="grid gap-6 lg:grid-cols-3">
        {/* Profile Card */}
        <div className="lg:col-span-1 bg-[hsl(var(--card))] rounded-xl border border-[hsl(var(--border))] shadow-sm overflow-hidden">
          <div className="flex flex-col items-center p-6 text-center">
            <div className="relative mb-4">
              <Avatar className="h-24 w-24 ring-4 ring-[hsl(var(--primary)/0.15)]">
                <AvatarImage src={user.avatar} alt={user.name} />
                <AvatarFallback className="text-2xl font-display">{user.name.charAt(0).toUpperCase()}</AvatarFallback>
              </Avatar>
              <span className={`absolute bottom-1 right-1 h-4 w-4 rounded-full border-2 border-[hsl(var(--card))] ${user.isOnline ? 'bg-emerald-500' : 'bg-slate-300 dark:bg-slate-600'}`} />
            </div>
            <h2 className="text-xl font-bold font-display">{user.name}</h2>
            {user.username && (
              <p className="text-sm text-[hsl(var(--muted-foreground))]">@{user.username}</p>
            )}
            <div className="mt-3 flex flex-wrap gap-2 justify-center">
              <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase ${
                user.role === 'superadmin'
                  ? 'bg-amber-100 text-amber-700 dark:bg-amber-900/20 dark:text-amber-400 border border-amber-200/50'
                  : user.role === 'admin'
                  ? 'bg-[hsl(var(--primary)/0.1)] text-[hsl(var(--primary))] border border-[hsl(var(--primary)/0.2)]'
                  : 'bg-[hsl(var(--muted))] text-[hsl(var(--muted-foreground))]'
              }`}>
                {user.role}
              </span>
              <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold uppercase ${
                user.isBlocked
                  ? 'bg-rose-100 text-rose-700 dark:bg-rose-900/20 dark:text-rose-400'
                  : 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/20 dark:text-emerald-400'
              }`}>
                <span className={`h-1.5 w-1.5 rounded-full ${user.isBlocked ? 'bg-rose-500' : 'bg-emerald-500'}`} />
                {user.isBlocked ? 'Banned' : 'Active'}
              </span>
              {user.isVerified && (
                <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold uppercase bg-emerald-100 text-emerald-700 dark:bg-emerald-900/20 dark:text-emerald-400">
                  Verified
                </span>
              )}
            </div>

            {user.bio && <p className="mt-4 text-sm text-[hsl(var(--muted-foreground))]">{user.bio}</p>}

            <div className="mt-6 w-full space-y-3 text-left text-sm">
              <div className="flex items-center gap-2">
                <Mail className="h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                <span>{user.email}</span>
              </div>
              {user.phone && (
                <div className="flex items-center gap-2">
                  <Phone className="h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                  <span>{user.phone}</span>
                </div>
              )}
              {user.location && (
                <div className="flex items-center gap-2">
                  <MapPin className="h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                  <span>{user.location}</span>
                </div>
              )}
              <div className="flex items-center gap-2">
                <Calendar className="h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                <span>Joined {formatDate(user.createdAt)}</span>
              </div>
            </div>

            {/* Actions */}
            <div className="mt-6 flex w-full flex-col gap-2">
              <Button
                variant={user.isBlocked ? 'default' : 'destructive'}
                onClick={() => banMutation.mutate()}
                disabled={banMutation.isPending}
                className="w-full"
              >
                <Ban className="mr-2 h-4 w-4" />
                {banMutation.isPending ? 'Processing...' : user.isBlocked ? 'Unban User' : 'Ban User'}
              </Button>
              {currentUser?.role === 'superadmin' && (
                <div className="flex gap-2">
                  {['student', 'admin', 'superadmin']
                    .filter((r) => r !== user.role)
                    .map((role) => (
                      <Button
                        key={role}
                        variant="outline"
                        size="sm"
                        className="flex-1"
                        onClick={() => roleMutation.mutate(role)}
                        disabled={roleMutation.isPending}
                      >
                        Set {role}
                      </Button>
                    ))}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Stats & Info */}
        <div className="lg:col-span-2 space-y-6">
          <div className="grid gap-4 md:grid-cols-3">
            {[
              { label: 'Listings', value: user.listingsCount ?? user.totalListings, icon: BookOpen, color: '#0D9488', bg: 'bg-[#0D9488]/10' },
              { label: `Rating (${user.totalReviews} reviews)`, value: user.averageRating?.toFixed(1) ?? '0.0', icon: Star, color: '#F59E0B', bg: 'bg-[#F59E0B]/10' },
              { label: 'Sold', value: user.totalSold, icon: BookOpen, color: '#3B82F6', bg: 'bg-[#3B82F6]/10' },
            ].map((s) => (
              <div key={s.label} className="flex items-center gap-3 bg-[hsl(var(--card))] px-4 py-4 rounded-xl border border-[hsl(var(--border))] shadow-sm">
                <div className={`h-10 w-10 rounded-full ${s.bg} flex items-center justify-center shrink-0`}>
                  <s.icon className="h-5 w-5" style={{ color: s.color }} />
                </div>
                <div>
                  <p className="text-sm font-medium text-[hsl(var(--muted-foreground))]">{s.label}</p>
                  <p className="text-xl font-bold font-display">{s.value}</p>
                </div>
              </div>
            ))}
          </div>

          <div className="bg-[hsl(var(--card))] rounded-xl border border-[hsl(var(--border))] shadow-sm overflow-hidden">
            <div className="px-6 py-4 border-b border-[hsl(var(--border))]">
              <h3 className="text-sm font-bold uppercase tracking-wider text-[hsl(var(--muted-foreground))]">Account Information</h3>
            </div>
            <div className="p-6">
              <div className="grid gap-4 md:grid-cols-2">
                <div>
                  <p className="text-sm font-medium text-[hsl(var(--muted-foreground))]">Last Active</p>
                  <p className="text-sm">{user.lastActive ? formatDate(user.lastActive) : 'Never'}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-[hsl(var(--muted-foreground))]">Google Linked</p>
                  <p className="text-sm">{user.googleId ? 'Yes' : 'No'}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-[hsl(var(--muted-foreground))]">Email Verified</p>
                  <p className="text-sm">{user.isVerified ? 'Yes' : 'No'}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-[hsl(var(--muted-foreground))]">Online Status</p>
                  <p className="text-sm">{user.isOnline ? 'Online' : 'Offline'}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
