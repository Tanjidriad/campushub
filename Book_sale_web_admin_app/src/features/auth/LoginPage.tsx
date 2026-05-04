import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '@/context/AuthContext'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { GraduationCap, Eye, EyeOff, ArrowRight, Loader2 } from 'lucide-react'
import { toast } from 'sonner'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const { login } = useAuth()
  const navigate = useNavigate()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!email || !password) {
      toast.error('Please fill in all fields')
      return
    }
    setIsLoading(true)
    try {
      await login(email, password)
      toast.success('Welcome back!')
      navigate('/dashboard', { replace: true })
    } catch (err: unknown) {
      const error = err as { response?: { data?: { message?: string } }; message?: string }
      toast.error(error.response?.data?.message || error.message || 'Login failed')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden bg-[#F0FDFA] dark:bg-[hsl(var(--background))]">
      {/* Decorative blurs */}
      <div className="absolute -top-[10%] -left-[5%] h-96 w-96 rounded-full bg-[hsl(var(--primary)/0.15)] blur-[80px]" />
      <div className="absolute -bottom-[10%] -right-[5%] h-80 w-80 rounded-full bg-amber-200/25 blur-[80px] dark:bg-amber-900/15" />

      <div className="relative z-10 w-full max-w-md mx-auto p-4">
        {/* Glass Card */}
        <div className="glass rounded-2xl shadow-xl p-8 sm:p-10 flex flex-col gap-6 animate-fade-in">
          {/* Header */}
          <div className="flex flex-col items-center text-center gap-4">
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-[hsl(var(--primary))] to-teal-700 flex items-center justify-center shadow-lg shadow-[hsl(var(--primary)/0.3)]">
              <GraduationCap className="h-8 w-8 text-white" />
            </div>
            <div className="flex flex-col items-center gap-2">
              <h1 className="text-2xl sm:text-3xl font-bold tracking-tight font-display">CampusHub</h1>
              <div className="bg-[hsl(var(--primary)/0.1)] text-[hsl(var(--primary))] text-xs font-semibold px-3 py-1 rounded-full uppercase tracking-wider">
                Admin Panel
              </div>
            </div>
            <p className="text-[hsl(var(--muted-foreground))] text-sm sm:text-base mt-2">
              Sign in to manage your campus marketplace
            </p>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="flex flex-col gap-5 mt-4">
            <div className="space-y-1.5">
              <label className="text-sm font-medium ml-1" htmlFor="email">
                Email
              </label>
              <Input
                id="email"
                type="email"
                placeholder="admin@campushub.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                disabled={isLoading}
                className="h-12"
              />
            </div>
            <div className="space-y-1.5">
              <label className="text-sm font-medium ml-1" htmlFor="password">
                Password
              </label>
              <div className="relative">
                <Input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  placeholder="Enter your password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  disabled={isLoading}
                  className="h-12 pr-12"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 rounded-md p-1 text-[hsl(var(--muted-foreground))] transition-colors hover:text-[hsl(var(--foreground))]"
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            <Button
              type="submit"
              className="h-12 w-full mt-2 text-base font-semibold gap-2 bg-gradient-to-r from-[hsl(var(--primary))] to-teal-600 hover:from-teal-600 hover:to-[hsl(var(--primary))] shadow-lg shadow-[hsl(var(--primary)/0.25)]"
              disabled={isLoading}
            >
              {isLoading ? (
                <>
                  <Loader2 className="h-5 w-5 animate-spinner" />
                  Signing in…
                </>
              ) : (
                <>
                  Sign In
                  <ArrowRight className="h-4 w-4" />
                </>
              )}
            </Button>
          </form>

          {/* Footer */}
          <p className="mt-4 text-center text-[11px] text-[hsl(var(--muted-foreground))]">
            CampusHub Admin Panel v1.0
          </p>
        </div>
      </div>
    </div>
  )
}
