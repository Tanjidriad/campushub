const jwt = require('jsonwebtoken');
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-secret';
process.env.JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'test-refresh-secret';

// Mock User model
const mockUser = {
    _id: 'user123',
    id: 'user123',
    email: 'test@example.com',
    name: 'Test User',
    role: 'student',
    isBlocked: false,
    isVerified: true,
    refreshToken: null,
    save: jest.fn().mockResolvedValue(true),
    select: jest.fn(),
};

jest.mock('../models/User', () => {
    const findById = jest.fn();
    findById.mockReturnValue({
        select: jest.fn().mockResolvedValue(mockUser),
    });
    return {
        findById,
        findByIdAndUpdate: jest.fn().mockReturnValue({ exec: jest.fn() }),
        findOne: jest.fn(),
    };
});

jest.mock('../utils/hashToken', () => jest.fn((t) => `hashed_${t}`));

const { protect, optionalAuth } = require('../middleware/auth');
const User = require('../models/User');

describe('Auth Middleware', () => {
    let req, res, next;

    beforeEach(() => {
        req = { headers: {} };
        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn().mockReturnThis(),
        };
        next = jest.fn();
        jest.clearAllMocks();
    });

    describe('protect', () => {
        it('should return 401 when no token is provided', async () => {
            await protect(req, res, next);

            expect(res.status).toHaveBeenCalledWith(401);
            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({ success: false, message: expect.stringContaining('no token') })
            );
            expect(next).not.toHaveBeenCalled();
        });

        it('should return 401 for invalid token', async () => {
            req.headers.authorization = 'Bearer invalidtoken';

            await protect(req, res, next);

            expect(res.status).toHaveBeenCalledWith(401);
            expect(next).not.toHaveBeenCalled();
        });

        it('should call next and set req.user for valid token', async () => {
            const token = jwt.sign({ id: 'user123' }, process.env.JWT_SECRET || 'test-secret');
            req.headers.authorization = `Bearer ${token}`;

            User.findById.mockReturnValue({
                select: jest.fn().mockResolvedValue(mockUser),
            });

            await protect(req, res, next);

            expect(req.user).toBeDefined();
            expect(req.user.id).toBe('user123');
            expect(next).toHaveBeenCalled();
        });

        it('should return 401 when user is not found', async () => {
            const token = jwt.sign({ id: 'nonexistent' }, process.env.JWT_SECRET || 'test-secret');
            req.headers.authorization = `Bearer ${token}`;

            User.findById.mockReturnValue({
                select: jest.fn().mockResolvedValue(null),
            });

            await protect(req, res, next);

            expect(res.status).toHaveBeenCalledWith(401);
            expect(next).not.toHaveBeenCalled();
        });

        it('should return 403 when user is blocked', async () => {
            const token = jwt.sign({ id: 'user123' }, process.env.JWT_SECRET || 'test-secret');
            req.headers.authorization = `Bearer ${token}`;

            User.findById.mockReturnValue({
                select: jest.fn().mockResolvedValue({ ...mockUser, isBlocked: true }),
            });

            await protect(req, res, next);

            expect(res.status).toHaveBeenCalledWith(403);
            expect(next).not.toHaveBeenCalled();
        });

        it('should return 401 with TOKEN_EXPIRED code for expired token', async () => {
            const token = jwt.sign({ id: 'user123' }, process.env.JWT_SECRET || 'test-secret', { expiresIn: '0s' });
            req.headers.authorization = `Bearer ${token}`;

            // Small delay so the token is actually expired
            await new Promise((r) => setTimeout(r, 10));

            await protect(req, res, next);

            expect(res.status).toHaveBeenCalledWith(401);
            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({ code: 'TOKEN_EXPIRED' })
            );
        });
    });

    describe('optionalAuth', () => {
        it('should call next without setting user when no token', async () => {
            await optionalAuth(req, res, next);

            expect(req.user).toBeUndefined();
            expect(next).toHaveBeenCalled();
        });

        it('should set user when valid token is provided', async () => {
            const token = jwt.sign({ id: 'user123' }, process.env.JWT_SECRET || 'test-secret');
            req.headers.authorization = `Bearer ${token}`;

            User.findById.mockReturnValue({
                select: jest.fn().mockResolvedValue(mockUser),
            });

            await optionalAuth(req, res, next);

            expect(req.user).toBeDefined();
            expect(next).toHaveBeenCalled();
        });
    });
});
