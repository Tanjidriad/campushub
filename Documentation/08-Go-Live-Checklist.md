# Production Go-Live Checklist

Use this checklist before promoting to production.

## Security

- [ ] `JWT_SECRET` and `JWT_REFRESH_SECRET` are strong and not placeholders.
- [ ] `FRONTEND_URL` contains explicit allowed origins only.
- [ ] CORS rejects unknown origins in staging validation.
- [ ] No plaintext secrets are committed to git history.

## CI and Quality Gates

- [ ] Backend CI passes (`npm test` in `book_backend`).
- [ ] Frontend CI passes (`typecheck`, `lint`, `test`, `build` in `Book_sale_web_admin_app`).
- [ ] Flutter checks pass (`flutter analyze`, `flutter test`).

## Critical Flow Testing

- [ ] Admin login works with valid credentials.
- [ ] Protected routes redirect unauthenticated users.
- [ ] Token refresh path succeeds with valid token and rejects replay token.
- [ ] Core admin CRUD flows (users/listings/categories) pass smoke tests.

## Observability and Operations

- [ ] Backend structured logs are visible in production log sink.
- [ ] Frontend unhandled errors are captured through monitoring endpoint (if configured).
- [ ] Health endpoint (`/health`) is monitored and alerting is configured.
- [ ] Rollback steps are tested once in staging.

## Release Approval

- [ ] Product owner approval
- [ ] Engineering sign-off
- [ ] Deployment window confirmed
