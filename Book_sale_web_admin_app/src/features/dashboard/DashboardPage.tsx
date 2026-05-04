import { useQuery } from '@tanstack/react-query'
import { adminApi } from '@/api/admin'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { useNavigate } from 'react-router-dom'
import {
  Users, BookOpen, AlertTriangle, Clock, TrendingUp, Eye,
  ArrowUpRight, ArrowDownRight, ArrowRight, Sparkles, ShoppingBag, DollarSign,
} from 'lucide-react'
import { timeAgo } from '@/lib/utils'
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
  LineChart,
  Line,
} from 'recharts'

const COLORS = [
  '#0D9488',
  '#3B82F6',
  '#F59E0B',
  '#EF4444',
  '#8B5CF6',
]

const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

// Mini sparkline data generator (simulated trend)
function generateSparkline(base: number, count = 7) {
  const data = []
  for (let i = 0; i < count; i++) {
    data.push({ v: Math.max(0, base + Math.round((Math.random() - 0.35) * base * 0.4)) })
  }
  return data
}

export default function DashboardPage() {
  const navigate = useNavigate()

  const { data: dashboard, isLoading: dashLoading } = useQuery({
    queryKey: ['dashboard'],
    queryFn: adminApi.getDashboard,
    refetchInterval: 30000,
  })

  const { data: activities, isLoading: actLoading } = useQuery({
    queryKey: ['activity', 10],
    queryFn: () => adminApi.getActivity(10),
    refetchInterval: 30000,
  })

  if (dashLoading) {
    return (
      <div className="space-y-6 animate-fade-in">
        <Skeleton className="h-24 rounded-xl" />
        <div className="grid gap-5 md:grid-cols-2 lg:grid-cols-4 stagger-children">
          {Array.from({ length: 4 }).map((_, i) => (
            <Skeleton key={i} className="h-40 rounded-xl" />
          ))}
        </div>
        <div className="grid gap-5 lg:grid-cols-2 stagger-children">
          <Skeleton className="h-80 rounded-xl" />
          <Skeleton className="h-80 rounded-xl" />
        </div>
      </div>
    )
  }

  const stats = [
    {
      title: 'Total Users',
      value: dashboard?.users.total ?? 0,
      change: `+${dashboard?.users.today ?? 0}`,
      subtitle: 'today',
      icon: Users,
      stripColor: '#0D9488',
      iconBg: 'bg-[#0D9488]/10',
      accentColor: '#0D9488',
      sparkColor: '#0D9488',
      trend: 'up' as const,
    },
    {
      title: 'Active Listings',
      value: dashboard?.listings.approved ?? 0,
      change: `${dashboard?.listings.total ?? 0}`,
      subtitle: 'total',
      icon: BookOpen,
      stripColor: '#3B82F6',
      iconBg: 'bg-blue-500/10',
      accentColor: '#3B82F6',
      sparkColor: '#3B82F6',
      trend: 'up' as const,
    },
    {
      title: 'Pending Review',
      value: dashboard?.listings.pending ?? 0,
      change: `+${dashboard?.listings.today ?? 0}`,
      subtitle: 'new today',
      icon: Clock,
      stripColor: '#F59E0B',
      iconBg: 'bg-amber-500/10',
      accentColor: '#F59E0B',
      sparkColor: '#F59E0B',
      trend: 'up' as const,
    },
    {
      title: 'Open Reports',
      value: dashboard?.reports.pending ?? 0,
      change: `${dashboard?.reports.pending ?? 0}`,
      subtitle: 'pending',
      icon: AlertTriangle,
      stripColor: '#EF4444',
      iconBg: 'bg-red-500/10',
      accentColor: '#EF4444',
      sparkColor: '#EF4444',
      trend: 'down' as const,
    },
  ]

  const userChartData = (dashboard?.charts.usersByMonth ?? []).map((d) => ({
    month: monthNames[d._id] || d._id,
    users: d.count,
  }))

  const categoryData = (dashboard?.charts.listingsByCategory ?? []).slice(0, 5).map((d, i) => ({
    ...d,
    fill: COLORS[i % COLORS.length],
    percentage: 0,
  }))

  // Calculate percentages for progress bars
  const maxCategoryCount = Math.max(...categoryData.map(d => d.count), 1)
  categoryData.forEach(d => {
    d.percentage = Math.round((d.count / maxCategoryCount) * 100)
  })

  const statusData = [
    { name: 'Approved', value: dashboard?.listings.approved ?? 0, fill: '#0D9488' },
    { name: 'Pending', value: dashboard?.listings.pending ?? 0, fill: '#F59E0B' },
    { name: 'Other', value: Math.max(0, (dashboard?.listings.total ?? 0) - (dashboard?.listings.approved ?? 0) - (dashboard?.listings.pending ?? 0)), fill: '#3B82F6' },
  ].filter(d => d.value > 0)

  return (
    <div className="space-y-6">
      {/* Welcome Banner */}
      <div className="relative rounded-2xl overflow-hidden shadow-sm bg-gradient-to-r from-[#0D9488] to-[#0f766e] text-white p-8 sm:p-10 animate-fade-in">
        <div className="absolute -top-20 -right-20 w-80 h-80 bg-white opacity-5 rounded-full blur-3xl" />
        <div className="absolute -bottom-20 -left-20 w-60 h-60 bg-white opacity-5 rounded-full blur-2xl" />
        <div className="relative z-10 flex items-center justify-between">
          <div>
            <h2 className="text-3xl sm:text-4xl font-bold tracking-tight font-display">Good Morning, Admin \uD83D\uDC4B</h2>
            <p className="text-teal-100 text-lg mt-2">Here's what's happening with your platform today.</p>
          </div>
          <div className="hidden sm:flex gap-3">
            <Button
              className="bg-white/20 hover:bg-white/30 text-white border-0 backdrop-blur-sm shadow-none"
              onClick={() => navigate('/pending')}
            >
              <Clock className="mr-2 h-4 w-4" />
              Review Pending
            </Button>
          </div>
        </div>
      </div>

      {/* Stat Cards with Colored Backgrounds */}
      <div className="grid gap-5 md:grid-cols-2 lg:grid-cols-4 stagger-children">
        {stats.map((stat) => {
          const sparkData = generateSparkline(stat.value)
          return (
            <Card key={stat.title} className="overflow-hidden relative shadow-sm hover:shadow-md transition-shadow duration-300">
              <div className="absolute left-0 top-0 bottom-0 w-[3.5px]" style={{ backgroundColor: stat.stripColor }} />
              <CardContent className="p-5 pl-6">
                <div className="flex items-start justify-between mb-3">
                  <div className={`rounded-lg p-2.5 ${stat.iconBg}`}>
                    <stat.icon className="h-5 w-5" style={{ color: stat.accentColor }} />
                  </div>
                  <div className="flex items-center gap-1">
                    {stat.trend === 'up' ? (
                      <ArrowUpRight className="h-4 w-4" style={{ color: stat.accentColor }} />
                    ) : (
                      <ArrowDownRight className="h-4 w-4" style={{ color: stat.accentColor }} />
                    )}
                    <span className="text-xs font-semibold" style={{ color: stat.accentColor }}>
                      {stat.change}
                    </span>
                  </div>
                </div>
                <h3 className="text-2xl font-bold animate-count-up">{stat.value.toLocaleString()}</h3>
                <p className="text-sm font-medium text-[hsl(var(--muted-foreground))] mt-0.5">{stat.title}</p>
                {/* Mini sparkline */}
                <div className="h-12 -mx-1 mt-3">
                  <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={sparkData}>
                      <defs>
                        <linearGradient id={`spark-${stat.title}`} x1="0" y1="0" x2="0" y2="1">
                          <stop offset="0%" stopColor={stat.sparkColor} stopOpacity={0.25} />
                          <stop offset="100%" stopColor={stat.sparkColor} stopOpacity={0} />
                        </linearGradient>
                      </defs>
                      <Area
                        type="monotone"
                        dataKey="v"
                        stroke={stat.sparkColor}
                        strokeWidth={2}
                        fill={`url(#spark-${stat.title})`}
                        dot={false}
                        isAnimationActive={false}
                      />
                    </AreaChart>
                  </ResponsiveContainer>
                </div>
              </CardContent>
            </Card>
          )
        })}
      </div>

      {/* Revenue Updates + Yearly Breakup + Monthly */}
      <div className="grid gap-5 lg:grid-cols-8">
        {/* User Growth — wider */}
        <Card className="lg:col-span-5 animate-fade-in-up" style={{ animationDelay: '150ms' }}>
          <CardHeader className="pb-2">
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="text-base font-semibold">User Growth</CardTitle>
                <p className="text-xs text-[hsl(var(--muted-foreground))] mt-0.5">Overview of new users</p>
              </div>
              <div className="flex items-center gap-4 text-xs">
                <div className="flex items-center gap-1.5">
                  <div className="h-2 w-2 rounded-full bg-[#0D9488]" />
                  <span className="text-[hsl(var(--muted-foreground))]">New Users</span>
                </div>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={290}>
              <AreaChart data={userChartData}>
                <defs>
                  <linearGradient id="userGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#0D9488" stopOpacity={0.15} />
                    <stop offset="95%" stopColor="#0D9488" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(220, 13%, 91%)" vertical={false} />
                <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#a1aab2' }} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#a1aab2' }} />
                <Tooltip
                  contentStyle={{
                    borderRadius: '8px',
                    border: 'none',
                    boxShadow: '0 4px 20px rgba(0,0,0,0.1)',
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                  }}
                />
                <Area
                  type="monotone"
                  dataKey="users"
                  stroke="#0D9488"
                  strokeWidth={2.5}
                  fill="url(#userGrad)"
                  dot={{ r: 3, fill: '#0D9488', stroke: '#fff', strokeWidth: 2 }}
                  activeDot={{ r: 5, stroke: '#0D9488', strokeWidth: 2 }}
                  animationDuration={1200}
                  animationBegin={200}
                />
              </AreaChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Listing Breakup — smaller column */}
        <div className="lg:col-span-3 grid gap-5">
          {/* Yearly Breakup — donut */}
          <Card className="animate-fade-in-up" style={{ animationDelay: '250ms' }}>
            <CardHeader className="pb-1">
              <CardTitle className="text-base font-semibold">Listing Breakup</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-4">
                <div className="flex-1">
                  <h3 className="text-2xl font-bold">{(dashboard?.listings.total ?? 0).toLocaleString()}</h3>
                  <div className="flex items-center gap-1.5 mt-1">
                    <span className="inline-flex items-center gap-0.5 rounded-full bg-[#0D9488]/10 px-2 py-0.5 text-xs font-semibold text-[#0D9488]">
                      <ArrowUpRight className="h-3 w-3" />
                      +{dashboard?.listings.today ?? 0}
                    </span>
                    <span className="text-xs text-[hsl(var(--muted-foreground))]">today</span>
                  </div>
                  <div className="mt-4 space-y-2.5">
                    {statusData.map((item) => (
                      <div key={item.name} className="flex items-center gap-2">
                        <div className="h-2.5 w-2.5 rounded-full" style={{ backgroundColor: item.fill }} />
                        <span className="text-xs text-[hsl(var(--muted-foreground))]">{item.name}</span>
                      </div>
                    ))}
                  </div>
                </div>
                <div className="w-[130px] h-[130px]">
                  <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                      <Pie
                        data={statusData}
                        cx="50%"
                        cy="50%"
                        innerRadius={38}
                        outerRadius={58}
                        paddingAngle={3}
                        dataKey="value"
                        animationDuration={1000}
                        stroke="none"
                      >
                        {statusData.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={entry.fill} />
                        ))}
                      </Pie>
                    </PieChart>
                  </ResponsiveContainer>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Monthly Earnings */}
          <Card className="animate-fade-in-up" style={{ animationDelay: '350ms' }}>
            <CardHeader className="pb-1">
              <CardTitle className="text-base font-semibold">Monthly Activity</CardTitle>
            </CardHeader>
            <CardContent>
              <h3 className="text-2xl font-bold">{(dashboard?.users.today ?? 0) + (dashboard?.listings.today ?? 0)}</h3>
              <p className="text-xs text-[hsl(var(--muted-foreground))] mt-0.5">Actions today</p>
              <div className="mt-3 h-16">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={[
                    { d: 'Mon', v: 4 }, { d: 'Tue', v: 7 }, { d: 'Wed', v: 5 },
                    { d: 'Thu', v: 9 }, { d: 'Fri', v: 6 }, { d: 'Sat', v: 3 }, { d: 'Sun', v: 2 },
                  ]}>
                    <Bar dataKey="v" fill="#0D9488" radius={[4, 4, 0, 0]} barSize={12} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Top Categories with Progress Bars + Listing Status Pie + Quick Stats */}
      <div className="grid gap-5 lg:grid-cols-12">
        {/* Top Categories */}
        <Card className="lg:col-span-4 animate-fade-in-up" style={{ animationDelay: '400ms' }}>
          <CardHeader className="pb-3">
            <div className="flex items-center justify-between">
              <CardTitle className="text-base font-semibold">Best Selling Categories</CardTitle>
              <Button variant="ghost" size="sm" onClick={() => navigate('/categories')} className="text-xs h-7 px-2 text-[hsl(var(--primary))]">
                View All
              </Button>
            </div>
            <p className="text-xs text-[hsl(var(--muted-foreground))]">Overview by category</p>
          </CardHeader>
          <CardContent className="space-y-4">
            {categoryData.map((cat, i) => (
              <div key={cat._id}>
                <div className="flex items-center justify-between mb-1.5">
                  <div className="flex items-center gap-2.5">
                    <div className="h-8 w-8 rounded-lg flex items-center justify-center" style={{ backgroundColor: `${COLORS[i % COLORS.length]}20` }}>
                      <BookOpen className="h-4 w-4" style={{ color: COLORS[i % COLORS.length] }} />
                    </div>
                    <div>
                      <p className="text-sm font-medium leading-tight">{cat._id}</p>
                      <p className="text-xs text-[hsl(var(--muted-foreground))]">{cat.count} listings</p>
                    </div>
                  </div>
                  <span className="text-xs font-semibold text-[hsl(var(--muted-foreground))]">{cat.percentage}%</span>
                </div>
                <Progress
                  value={cat.percentage}
                  size="sm"
                  indicatorClassName="rounded-full"
                  className="ml-[42px]"
                />
              </div>
            ))}
            {categoryData.length === 0 && (
              <p className="text-sm text-center text-[hsl(var(--muted-foreground))] py-8">No categories yet</p>
            )}
          </CardContent>
        </Card>

        {/* Top Categories Bar Chart */}
        <Card className="lg:col-span-5 animate-fade-in-up" style={{ animationDelay: '450ms' }}>
          <CardHeader className="pb-2">
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="text-base font-semibold">Listings by Category</CardTitle>
                <p className="text-xs text-[hsl(var(--muted-foreground))] mt-0.5">Distribution chart</p>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={categoryData} barSize={28}>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(220, 13%, 91%)" vertical={false} />
                <XAxis dataKey="_id" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#a1aab2' }} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#a1aab2' }} />
                <Tooltip
                  contentStyle={{
                    borderRadius: '8px',
                    border: 'none',
                    boxShadow: '0 4px 20px rgba(0,0,0,0.1)',
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                  }}
                  cursor={{ fill: 'rgba(13, 148, 136, 0.06)', radius: 6 }}
                />
                <Bar dataKey="count" radius={[6, 6, 0, 0]} animationDuration={1000}>
                  {categoryData.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Quick Stats Column */}
        <div className="lg:col-span-3 grid gap-5 content-start">
          {/* Platform stat card 1 */}
          <Card className="animate-fade-in-up border-0" style={{ animationDelay: '500ms' }}>
            <CardContent className="p-5">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs font-medium text-[hsl(var(--muted-foreground))]">Total Listed</p>
                  <h3 className="text-xl font-bold mt-0.5">{(dashboard?.listings.total ?? 0).toLocaleString()}</h3>
                </div>
                <div className="rounded-xl p-2.5 bg-[#0D9488]/10">
                  <ShoppingBag className="h-5 w-5 text-[#0D9488]" />
                </div>
              </div>
              <Progress
                value={75}
                size="sm"
                className="mt-3"
                indicatorClassName="bg-[#0D9488]"
              />
            </CardContent>
          </Card>

          {/* Platform stat card 2 */}
          <Card className="animate-fade-in-up border-0" style={{ animationDelay: '550ms' }}>
            <CardContent className="p-5">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs font-medium text-[hsl(var(--muted-foreground))]">Users Today</p>
                  <h3 className="text-xl font-bold mt-0.5">{dashboard?.users.today ?? 0}</h3>
                </div>
                <div className="rounded-xl p-2.5 bg-[#3B82F6]/10">
                  <Users className="h-5 w-5 text-[#3B82F6]" />
                </div>
              </div>
              <Progress
                value={45}
                size="sm"
                className="mt-3"
                indicatorClassName="bg-[#3B82F6]"
              />
            </CardContent>
          </Card>

          {/* Platform stat card 3 */}
          <Card className="animate-fade-in-up border-0" style={{ animationDelay: '600ms' }}>
            <CardContent className="p-5">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs font-medium text-[hsl(var(--muted-foreground))]">Pending Reports</p>
                  <h3 className="text-xl font-bold mt-0.5">{dashboard?.reports.pending ?? 0}</h3>
                </div>
                <div className="rounded-xl p-2.5 bg-[#EF4444]/10">
                  <AlertTriangle className="h-5 w-5 text-[#EF4444]" />
                </div>
              </div>
              <Progress
                value={30}
                size="sm"
                className="mt-3"
                indicatorClassName="bg-[#EF4444]"
              />
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Recent Activity */}
      <Card className="animate-fade-in-up" style={{ animationDelay: '650ms' }}>
        <CardHeader className="flex flex-row items-center justify-between pb-3">
          <div>
            <CardTitle className="text-base font-semibold">Recent Activity</CardTitle>
            <p className="text-xs text-[hsl(var(--muted-foreground))] mt-0.5">Latest platform events</p>
          </div>
          <Button variant="ghost" size="sm" onClick={() => navigate('/activity')} className="text-xs h-7 px-2 text-[hsl(var(--primary))]">
            View All <ArrowRight className="ml-1 h-3 w-3" />
          </Button>
        </CardHeader>
        <CardContent>
          {actLoading ? (
            <div className="space-y-3">
              {Array.from({ length: 4 }).map((_, i) => (
                <Skeleton key={i} className="h-14 rounded-lg" />
              ))}
            </div>
          ) : (
            <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-3">
              {activities?.slice(0, 6).map((item, idx) => (
                <div
                  key={item.id}
                  className="flex items-center gap-3 rounded-xl bg-[hsl(var(--muted)/0.5)] p-3 transition-all duration-200 hover:bg-[hsl(var(--muted))] animate-fade-in"
                  style={{ animationDelay: `${idx * 50}ms` }}
                >
                  <div className={`shrink-0 rounded-lg p-2 ${item.color === 'success' ? 'bg-[#0D9488]/10' :
                      item.color === 'warning' ? 'bg-[#F59E0B]/10' :
                        item.color === 'error' ? 'bg-[#EF4444]/10' :
                          'bg-[#3B82F6]/10'
                    }`}>
                    <Eye className={`h-4 w-4 ${item.color === 'success' ? 'text-[#0D9488]' :
                        item.color === 'warning' ? 'text-[#F59E0B]' :
                          item.color === 'error' ? 'text-[#EF4444]' :
                            'text-[#3B82F6]'
                      }`} />
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-medium truncate">{item.title}</p>
                    <p className="text-xs text-[hsl(var(--muted-foreground))] truncate">{item.subtitle}</p>
                  </div>
                  <span className="shrink-0 text-[10px] text-[hsl(var(--muted-foreground))]">
                    {timeAgo(item.timestamp || item.createdAt)}
                  </span>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Quick Actions */}
      <div className="grid gap-4 md:grid-cols-4 stagger-children">
        {[
          { label: `Review Pending (${dashboard?.listings.pending ?? 0})`, icon: Clock, to: '/pending', bg: 'bg-[#0D9488]', hover: 'hover:bg-[#0f766e]' },
          { label: `Open Reports (${dashboard?.reports.pending ?? 0})`, icon: AlertTriangle, to: '/reports', bg: 'bg-[#EF4444]', hover: 'hover:bg-[#DC2626]' },
          { label: 'Manage Users', icon: Users, to: '/users', bg: 'bg-[#3B82F6]', hover: 'hover:bg-[#2563EB]' },
          { label: 'Categories', icon: BookOpen, to: '/categories', bg: 'bg-[#F59E0B]', hover: 'hover:bg-[#D97706]' },
        ].map((action) => (
          <button
            key={action.label}
            onClick={() => navigate(action.to)}
            className={`flex items-center gap-3 rounded-xl p-4 text-white ${action.bg} ${action.hover} transition-all duration-200 active:scale-[0.98] shadow-sm`}
          >
            <action.icon className="h-5 w-5" />
            <span className="text-sm font-semibold">{action.label}</span>
          </button>
        ))}
      </div>
    </div>
  )
}
