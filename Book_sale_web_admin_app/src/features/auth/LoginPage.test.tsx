import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import LoginPage from './LoginPage'
import { useAuth } from '@/context/AuthContext'

const mockNavigate = vi.fn()
const mockToastSuccess = vi.fn()
const mockToastError = vi.fn()

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<typeof import('react-router-dom')>('react-router-dom')
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  }
})

vi.mock('@/context/AuthContext', () => ({
  useAuth: vi.fn(),
}))

vi.mock('sonner', () => ({
  toast: {
    success: (...args: unknown[]) => mockToastSuccess(...args),
    error: (...args: unknown[]) => mockToastError(...args),
  },
}))

const mockedUseAuth = vi.mocked(useAuth)

describe('LoginPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('submits valid credentials and navigates to dashboard', async () => {
    const login = vi.fn().mockResolvedValue(undefined)
    mockedUseAuth.mockReturnValue({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      login,
      logout: vi.fn(),
    })

    render(<LoginPage />)
    const user = userEvent.setup()

    await user.type(screen.getByLabelText('Email'), 'admin@campushub.com')
    await user.type(screen.getByLabelText('Password'), 'StrongPassword123!')
    await user.click(screen.getByRole('button', { name: /sign in/i }))

    await waitFor(() => expect(login).toHaveBeenCalledWith('admin@campushub.com', 'StrongPassword123!'))
    expect(mockToastSuccess).toHaveBeenCalled()
    expect(mockNavigate).toHaveBeenCalledWith('/dashboard', { replace: true })
  })

  it('shows validation error when fields are missing', async () => {
    mockedUseAuth.mockReturnValue({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      login: vi.fn(),
      logout: vi.fn(),
    })

    render(<LoginPage />)
    const user = userEvent.setup()

    await user.click(screen.getByRole('button', { name: /sign in/i }))

    expect(mockToastError).toHaveBeenCalledWith('Please fill in all fields')
  })
})
