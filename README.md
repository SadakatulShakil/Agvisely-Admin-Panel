# Agvisely Admin

Web admin panel for the DAE **Agvisely** app — Flutter Web + GetX, responsive
down to phones. Same architecture as the mobile app
([`SadakatulShakil/Agvisely`](https://github.com/SadakatulShakil/Agvisely)):
feature-first folders, `domen/binding` + `domen/controllers`, shared `core/`.

Built so far: **sign-in (phone + OTP)**, **Overview**, **User Management**.
Content (CMS) and Others are routed placeholders.

## Run

```bash
flutter pub get

# Demo data (default in debug). Any valid BD number signs in; code is 1234.
flutter run -d chrome

# Against the real backend
flutter run -d chrome \
  --dart-define=USE_MOCK=false \
  --dart-define=API_BASE_URL=http://192.168.68.52:3000/api/v1
```

| `--dart-define` | Default | Meaning |
| --- | --- | --- |
| `USE_MOCK` | `true` in debug, `false` in release | In-memory data for every repository |
| `API_BASE_URL` | mobile app's `baseUrlUser` | Same backend the app uses |

Release build: `flutter build web --release --dart-define=API_BASE_URL=…`

## Project layout

```
lib/
  main.dart                      session load → GetMaterialApp
  app/
    routes/app_routes.dart       URL paths
    routes/app_pages.dart        GetPage list: binding + guards per route
    middleware/route_guards.dart Root / Auth / Guest / Otp guards
    bindings/initial_binding.dart repositories (mock or remote)
    navigation.dart              top-nav items
  core/
    config/app_config.dart       dart-defines, OTP length, panel roles
    network/                     ApiClient (bearer, shared 401 refresh), endpoints, Json helpers
    services/session_service.dart tokens (secure storage) + admin profile + pending OTP phone
    mock/mock_store.dart         seeded demo data
    theme/                       colours from the admin Figma, Outfit + AnekBangla
    utils/                       PhoneUtil (same rules as app), Fmt, Resource<T>, breakpoints
    widgets/                     AdminShell, AppDataTable, PanelCard, dialogs, toasts…
  models/                        AuthUser, AdminUser, Paginated, Period, Rbac*, dashboard models
  features/
    auth/          login → OTP → role check → session
    dashboard/     Overview
    user_management/ directory, add user, suspend/restore, RBAC
    common/        Coming-soon + 404 pages
```

Each feature: `data/` (abstract repository + `Remote…` + `Mock…`),
`domen/binding`, `domen/controllers`, `presentation/pages|widgets`.

## Sign-in flow

1. `POST /users/login {phone}` — same endpoint as the app.
2. `POST /users/verify-otp {phone, otp, purpose: "login"}` → tokens.
3. `GET /users/me` (with the new token) → `role`.
4. Only `role ∈ {admin, super_admin}` (`AppConfig.panelRoles`) gets a
   session; anyone else's tokens are revoked via `POST /users/logout`.

401 handling mirrors the app: one shared `POST /users/refresh-token`, retry
once, otherwise clear the session and go to `/login`.

## Admin API contract (backend to implement)

All responses use the app's envelope `{ success, message, data }`.
All routes require `Authorization: Bearer <admin token>`; return **403** for
non-admin roles.

### `GET /admin/dashboard/summary?period=7d|30d|1y`
```json
{ "data": {
  "activeUsers":         { "value": 45946, "changePct": 12.6 },
  "newRegistrations":    { "value": 2698,  "changePct": -4.2, "otpVerifiedPct": 42.9 },
  "advisoriesDelivered": { "value": 3421,  "changePct": 9.6 },
  "upazilaCoverage":     { "value": 412,   "changePct": 12.6, "total": 495 }
}}
```
`changePct` is against the previous window of the same length.

### `GET /admin/users?page=1&limit=10&period=7d&search=&professionId=`
`period` filters by registration date; `search` matches name, phone, location.
```json
{ "data": [ {
    "id": 12, "name": "Khairul Islam", "phone": "01634987523",
    "profession": { "id": 3, "name": "DAE Official" },
    "role": "officer",
    "location": { "upazila": "Pallabi", "district": "Dhaka" },
    "status": "active",
    "createdAt": "2026-08-12T09:30:00Z" } ],
  "meta":   { "page": 1, "limit": 10, "total": 3487 },
  "counts": { "all": 54738,
              "professions": [ { "id": 1, "name": "Farmer", "count": 3487 } ] } }
```
`counts` respects `period` and `search` but **not** `professionId` (they
drive the tabs). `location` may also be a plain string.

### `PATCH /admin/users/:id/status` `{ "status": "active" | "inactive" }`
Returns the updated user. Suspending should also revoke that user's refresh
tokens so the app signs them out.

### `POST /admin/users`
`{ name, phone, professionId, role, location }` → created user.
Return **409** with a `message` if the phone already exists.

### `GET /admin/rbac` · `PUT /admin/rbac`
```json
{ "data": {
  "roles": [ { "key": "admin", "label": "Admin" }, { "key": "expert", "label": "Expert" },
             { "key": "officer", "label": "Officer" }, { "key": "farmer", "label": "Farmer" } ],
  "capabilities": [
    { "key": "send_push", "label": "Send push notifications",
      "options": ["full", "region", "own_upazila", "none"] },
    { "key": "manage_users", "label": "Manage users & roles",
      "options": ["full", "none"], "lockedRoles": ["admin"] } ],
  "grants": { "send_push": { "admin": "full", "expert": "region",
                             "officer": "own_upazila", "farmer": "none" } } } }
```
Levels: `full`, `own_modules`, `region`, `own_upazila`, `none`.
`PUT` body: `{ "grants": { … } }`; return the saved matrix. Reject changes
to `lockedRoles` server-side too.

### `GET /admin/advisories?limit=5&sort=-updatedAt`
```json
{ "data": [ { "id": 1, "crop": "Rice (Boro)", "stage": "Flowering", "area": "Dhaka",
  "trigger": "Tmax > 35°C", "advisory": "দুপুরে জমিতে ৫–৭ সেমি পানি ধরে রাখুন; সকালে সেচ দিন",
  "status": "published" } ] }
```
`PATCH /admin/advisories/:id/status` `{ "status": "published" | "suspended" }`
→ updated advisory.

### `GET /admin/data-sources` · `PUT /admin/data-sources/:id/default`
```json
{ "data": [ { "id": "bmd", "name": "BMD",
  "description": "Bangladesh Meteorological Department · Primary",
  "status": "operational", "lastSyncAt": "2026-10-25T06:00:00Z",
  "uptime30d": 99.8, "isDefault": true } ] }
```
`status`: `operational | degraded | pilot | down`. Exactly one default.

## Deploying

URLs are path-based (`/users`, not `/#/users`), so the host must serve
`index.html` for unknown paths, or refreshes and bookmarks 404.

- **Nginx:** `location / { try_files $uri $uri/ /index.html; }`
- **Firebase Hosting:** `"rewrites": [{ "source": "**", "destination": "/index.html" }]`
- **Netlify:** `/*  /index.html  200` in `_redirects`
- **Sub-path** (e.g. `/admin/`): `flutter build web --base-href /admin/`

The API must allow CORS from the panel's origin (`Authorization`,
`Content-Type`, `Accept-Language` headers; `GET POST PUT PATCH DELETE`).
Serve over HTTPS — secure storage on web needs a secure context
(`localhost` is fine for development).

## Notes

- Copy fixes vs. the Figma: User Management subtitle (the frame reused the
  CMS one), tab counts ("3,4874"), upazila coverage now shown "of 495",
  "Operationa" → "Operational", RBAC "Null" → "No access", login text
  rewritten for admins (the frame had sign-up copy).
- `DropdownButtonFormField.value` is kept (with an ignore) so the project
  builds on Flutter versions before 3.35, where `initialValue` was added.
