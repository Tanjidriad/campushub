import { useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { FileQuestion } from 'lucide-react'

export default function NotFoundPage() {
  const navigate = useNavigate()

  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center text-center animate-fade-in">
      <div className="animate-float">
        <FileQuestion className="mb-4 h-16 w-16 text-[hsl(var(--muted-foreground))] opacity-50" />
      </div>
      <h1 className="text-3xl font-bold animate-fade-in-up" style={{ animationDelay: '0.1s' }}>404 - Page Not Found</h1>
      <p className="mt-2 text-[hsl(var(--muted-foreground))] animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
        The page you're looking for doesn't exist or has been moved.
      </p>
      <Button className="mt-6 animate-fade-in-up" style={{ animationDelay: '0.3s' }} onClick={() => navigate('/dashboard')}>
        Go to Dashboard
      </Button>
    </div>
  )
}
