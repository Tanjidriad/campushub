# Frontend Operations and Rollback

## 1) Required Environment Variables

Set these in your frontend hosting provider:

- `VITE_API_BASE_URL` - Base API URL (for example `https://api.yourdomain.com/api`)
- `VITE_MONITORING_ENDPOINT` - Optional endpoint that accepts browser error events via `sendBeacon`

## 2) Deployment Steps

1. Pull latest code on `main`.
2. Install dependencies:
   - `cd Book_sale_web_admin_app`
   - `npm ci`
3. Validate quality gates:
   - `npm run typecheck`
   - `npm run lint`
   - `npm run test`
   - `npm run build`
4. Deploy generated `dist` folder via your hosting platform workflow.

## 3) Post-Deploy Smoke Checks

Validate in production immediately:

- Login flow works with valid admin credentials.
- Unauthenticated access to protected routes redirects to login.
- Dashboard, users, listings, and reports pages load successfully.
- API calls resolve against production backend URL.

## 4) Rollback Procedure

If deployment causes incidents:

1. Roll back to previous successful frontend build in host dashboard.
2. Verify `/login` and `/dashboard` load.
3. Confirm backend API health endpoint still reports healthy state.
4. Keep rollback active until fix branch passes all CI checks.

## 5) Incident Notes

When an incident occurs, capture:

- Deployment version/commit SHA
- Time started and recovered
- User impact summary
- Root cause and follow-up action item
