jest.mock('../utils/generateToken', () => ({
  generateTokens: jest.fn(),
}));

jest.mock('../utils/hashToken', () => jest.fn());

const { generateTokens } = require('../utils/generateToken');
const hashToken = require('../utils/hashToken');
const authController = require('../controllers/authController');

describe('Auth refresh-token response shape', () => {
  it('returns rotated tokens inside data payload', async () => {
    const req = {
      user: {
        _id: 'user-1',
        refreshToken: null,
        save: jest.fn().mockResolvedValue(undefined),
      },
    };
    const res = {
      json: jest.fn(),
    };
    const next = jest.fn();

    generateTokens.mockReturnValue({
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    });
    hashToken.mockReturnValue('hashed-refresh');

    authController.refreshToken(req, res, next);
    await new Promise((resolve) => setImmediate(resolve));

    expect(next).not.toHaveBeenCalled();
    expect(req.user.refreshToken).toBe('hashed-refresh');
    expect(req.user.save).toHaveBeenCalled();
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: {
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
      },
    });
  });
});

