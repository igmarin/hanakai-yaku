---
name: setup-authentication
version: "1.0.0"
license: MIT
description: >
  Use when implementing authentication in Hanami 2.x. Chains inject-dependencies,
  providers, create-action, and handle-errors.
ecosystem_sources:
  - hanami/hanami
  - hanami/hanami-controller
tags:
  - workflows
  - authentication
  - auth
  - security
---

# setup-authentication

Use this workflow when implementing authentication in Hanami 2.x.

**Core principle:** Authentication is explicit in every Action. No global magic — each Action declares its auth requirements.

---

## Quick Reference

| Step | Skill | Handoff Condition |
|---|---|---|
| 1. Setup DI | `inject-dependencies` | Auth service injectable via `Deps` |
| 2. Register provider | `providers` | Auth service registered in container |
| 3. Create Actions | `create-action` | Login, logout, protected endpoints |
| 4. Handle errors | `handle-errors` | 401/403 responses for auth failures |

---

## Core Process

1. **[Setup DI]** — Load skill: `inject-dependencies`
   - Create an authentication service object
   - Register it in the DI container
   - Inject it into Actions that need auth
   - Handoff condition: Auth service accessible via `Deps["authentication"]`

2. **[Register Provider]** — Load skill: `providers`
   - Create `config/providers/authentication.rb`
   - Register the auth service in the `start` block
   - Handoff condition: Auth service is registered and injectable

3. **[Create Actions]** — Load skill: `create-action`
   - Create login Action: validates credentials, sets session/token
   - Create logout Action: clears session/token
   - Create protected Actions: check auth before processing
   - Handoff condition: Login/logout work, protected endpoints require auth

4. **[Handle Errors]** — Load skill: `handle-errors`
   - Return 401 for missing/invalid credentials
   - Return 403 for insufficient permissions
   - Log auth failures (but not passwords)
   - Handoff condition: Correct error responses for auth failures

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll put auth in a base controller" | Hanami has no base controller. Each Action must explicitly check auth. |
| "I'll store passwords in plain text" | Always hash passwords with bcrypt or argon2. |
| "I'll skip session security configuration" | Configure secure sessions with `http_only`, `secure`, and `same_site`. |
| "I'll return specific error messages that reveal valid emails" | Return generic "Invalid credentials" for both missing user and wrong password. |
| "I'll forget to protect all endpoints that need auth" | Every Action that requires auth must explicitly check it. There is no automatic protection. |

---

## Red Flags

- Assumed auth by convention rather than explicit check
- Plain text password storage
- Missing session security config
- Specific error messages revealing valid users
- Unprotected endpoints that should require auth
- Auth logic scattered across Actions instead of centralized service

---

## Integration

| Related Skill | When to chain |
|---|---|
| **inject-dependencies** | Step 1: Inject auth service via `Deps`. |
| **providers** | Step 2: Register auth service in container. |
| **create-action** | Step 3: Create login/logout/protected Actions. |
| **handle-errors** | Step 4: Handle 401/403 responses. |
| **security-review** | Cross-reference security concerns. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Authentication) |
|---|---|
| `before_action :authenticate_user!` | Explicit auth check in each Action |
| `Devise` gem | Custom auth service + provider + Actions |
| `has_secure_password` | `BCrypt::Password.create` in auth service |
| `session[:user_id] = user.id` | Session management in Action or auth service |
| `current_user` helper | `include Deps["authentication"]` + `authentication.current_user(request)` |
| `sign_in`, `sign_out` | Custom login/logout Actions |
