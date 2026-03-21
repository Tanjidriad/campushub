const request = require('supertest');
const { app, server } = require('../server');

afterAll((done) => {
  if (server.listening) {
    server.close(done);
    return;
  }
  done();
});

describe('Basic API routes', () => {
  it('GET /api should return API info', async () => {
    const res = await request(app).get('/api');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('success', true);
    expect(res.body).toHaveProperty('endpoints');
  });

  it('GET /health should return health status', async () => {
    const res = await request(app).get('/health');
    expect([200, 503]).toContain(res.statusCode);
    expect(res.body).toHaveProperty('status');
  });
});

