const { validationResult } = require('express-validator');

// We need to test the validate middleware function and the rules
// The validate function checks validationResult and returns 400 on errors

// Mock Category model (used by some rules)
jest.mock('../models/Category', () => ({}));

const { validate, rules } = require('../middleware/validate');

describe('Validate Middleware', () => {
    let req, res, next;

    beforeEach(() => {
        req = { body: {}, params: {}, query: {} };
        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn().mockReturnThis(),
        };
        next = jest.fn();
    });

    describe('validate function', () => {
        it('should call next when there are no validation errors', async () => {
            // Run a rule that will pass
            const chain = rules.login;
            req.body = { email: 'test@test.com', password: 'password123' };

            for (const rule of chain) {
                await rule.run(req);
            }

            validate(req, res, next);

            expect(next).toHaveBeenCalled();
            expect(res.status).not.toHaveBeenCalled();
        });

        it('should return 400 when validation fails', async () => {
            const chain = rules.login;
            req.body = { email: 'invalid', password: '' };

            for (const rule of chain) {
                await rule.run(req);
            }

            validate(req, res, next);

            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({ success: false })
            );
            expect(next).not.toHaveBeenCalled();
        });
    });

    describe('rules.register', () => {
        it('should fail with invalid email', async () => {
            req.body = { email: 'notanemail', password: 'password123', name: 'Test' };

            for (const rule of rules.register) {
                await rule.run(req);
            }

            const errors = validationResult(req);
            expect(errors.isEmpty()).toBe(false);
        });

        it('should fail with short password', async () => {
            req.body = { email: 'test@test.com', password: '12', name: 'Test' };

            for (const rule of rules.register) {
                await rule.run(req);
            }

            const errors = validationResult(req);
            expect(errors.isEmpty()).toBe(false);
            expect(errors.array().some(e => e.msg.includes('6 characters'))).toBe(true);
        });

        it('should fail without name', async () => {
            req.body = { email: 'test@test.com', password: 'password123', name: '' };

            for (const rule of rules.register) {
                await rule.run(req);
            }

            const errors = validationResult(req);
            expect(errors.isEmpty()).toBe(false);
        });

        it('should pass with valid data', async () => {
            req.body = { email: 'test@test.com', password: 'password123', name: 'Test User' };

            for (const rule of rules.register) {
                await rule.run(req);
            }

            const errors = validationResult(req);
            expect(errors.isEmpty()).toBe(true);
        });
    });

    describe('rules.login', () => {
        it('should pass with valid credentials', async () => {
            req.body = { email: 'test@test.com', password: 'password123' };

            for (const rule of rules.login) {
                await rule.run(req);
            }

            const errors = validationResult(req);
            expect(errors.isEmpty()).toBe(true);
        });

        it('should fail with empty password', async () => {
            req.body = { email: 'test@test.com', password: '' };

            for (const rule of rules.login) {
                await rule.run(req);
            }

            const errors = validationResult(req);
            expect(errors.isEmpty()).toBe(false);
        });
    });

    describe('rules.createOffer', () => {
        it('should pass with valid offer data', async () => {
            req.body = { listingId: '507f1f77bcf86cd799439011', amount: 25.50 };

            for (const rule of rules.createOffer) {
                await rule.run(req);
            }

            const errors = validationResult(req);
            expect(errors.isEmpty()).toBe(true);
        });

        it('should fail with invalid listingId', async () => {
            req.body = { listingId: 'not-a-mongo-id', amount: 25 };

            for (const rule of rules.createOffer) {
                await rule.run(req);
            }

            const errors = validationResult(req);
            expect(errors.isEmpty()).toBe(false);
        });

        it('should fail with negative amount', async () => {
            req.body = { listingId: '507f1f77bcf86cd799439011', amount: -5 };

            for (const rule of rules.createOffer) {
                await rule.run(req);
            }

            const errors = validationResult(req);
            expect(errors.isEmpty()).toBe(false);
        });
    });

    describe('rules.mongoId', () => {
        it('should pass with valid MongoDB ObjectId', async () => {
            req.params = { id: '507f1f77bcf86cd799439011' };

            for (const rule of rules.mongoId) {
                await rule.run(req);
            }

            const errors = validationResult(req);
            expect(errors.isEmpty()).toBe(true);
        });

        it('should fail with invalid id', async () => {
            req.params = { id: 'invalid' };

            for (const rule of rules.mongoId) {
                await rule.run(req);
            }

            const errors = validationResult(req);
            expect(errors.isEmpty()).toBe(false);
        });
    });
});
