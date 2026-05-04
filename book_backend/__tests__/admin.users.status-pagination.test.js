const mockUserModel = {
  aggregate: jest.fn(),
  countDocuments: jest.fn(),
  find: jest.fn(),
};

jest.mock('../models/User', () => mockUserModel);
jest.mock('../models/Listing', () => ({}));
jest.mock('../models/Report', () => ({}));
jest.mock('../models', () => ({ Notification: {}, AuditLog: {} }));
jest.mock('../utils/auditLog', () => jest.fn());

const adminController = require('../controllers/adminController');

describe('Admin users active/offline pagination', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('uses filtered total count for active users pagination', async () => {
    const req = {
      query: {
        status: 'active',
        page: '1',
        limit: '2',
      },
    };
    const res = {
      json: jest.fn(),
    };
    const next = jest.fn();

    mockUserModel.aggregate
      .mockResolvedValueOnce([
        { _id: 'u1', email: 'a@test.com', isOnline: true },
        { _id: 'u2', email: 'b@test.com', isOnline: true },
      ])
      .mockResolvedValueOnce([{ total: 7 }]);

    mockUserModel.countDocuments.mockImplementation((query = {}) => {
      if (Object.keys(query).length === 0) return Promise.resolve(100);
      if (query.isBlocked && query.isBlocked.$ne === true) return Promise.resolve(91);
      if (query.isBlocked === true) return Promise.resolve(9);
      if (query.role === 'admin') return Promise.resolve(3);
      return Promise.resolve(0);
    });

    adminController.getUsers(req, res, next);
    await new Promise((resolve) => setImmediate(resolve));

    expect(next).not.toHaveBeenCalled();
    expect(mockUserModel.find).not.toHaveBeenCalled();
    expect(mockUserModel.aggregate).toHaveBeenCalledTimes(2);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: true,
        data: expect.any(Array),
        pagination: expect.objectContaining({
          total: 7,
          page: 1,
          limit: 2,
          totalPages: 4,
        }),
      })
    );
  });
});

