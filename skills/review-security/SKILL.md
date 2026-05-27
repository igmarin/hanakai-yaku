---
name: review-security
license: MIT
description: >
  Use when conducting a security audit, security review, vulnerability assessment, vulnerability check, or secure coding review on Hanami 2.x applications — validate params via the Params DSL in every Action, verify CSRF protection is enabled in config/app.rb, audit authentication checks via explicit `before :authenticate!`, check authorization with role/permission checks, never log passwords/tokens/secrets, use ROM query interface to prevent SQL injection (no string interpolation in `where("...")`), never use `raw` on user input in templates, store secrets in settings not hardcoded, and return generic error messages for auth failures. Validates parameter handling, CSRF, auth integration, XSS, session configuration, and hardening posture.
metadata:
  ecosystem_sources:
  - hanami/hanami
  tags:
  - security
  - review
  - csrf
  - authentication
  - vulnerabilities
  version: 1.0.0
---

# review-security

Use this skill when reviewing Hanami 2.x code for security concerns.

**Core principle:** Security is layered. Validate at the boundary, authenticate explicitly, and never trust input.

---

## Review Workflow

Follow this sequence when performing a security review. For each step, the **Red Flag** column indicates a failing condition; if a red flag is found, apply the remediation noted in **Core Rules** below.

| # | Concern | Grep / Check | Red Flag | Severity |
|---|---|---|---|---|
| 1 | **Param validation** | `grep -rn 'request.params' app/actions/ \| grep -v 'params do'` | `request.params` used directly in business logic without a `params` block | Critical |
| 2 | **CSRF protection** | Check `config/app.rb` for `config.actions.csrf_protection` | Missing `csrf_protection = true` for HTML endpoints | Critical |
| 3 | **Authentication** | `grep -rn 'def handle' app/actions/` cross-checked with `grep -rn 'authenticate'` | Auth assumed by convention, no explicit `before :authenticate!` | Critical |
| 4 | **Authorization** | Review Actions and service objects for role/permission checks | Only authn present, no authz | High |
| 5 | **Secrets in code** | `grep -rn 'secret\|password\|api_key\|token' app/ config/ --include='*.rb' \| grep -v 'settings\|ENV'` | Hardcoded strings for keys/secrets in source files | Critical |
| 6 | **Logging** | `grep -rn 'logger' app/ \| grep 'password\|token\|secret'` | `params[:password]` or tokens in log calls | High |
| 7 | **SQL injection** | `grep -rn 'where("' app/` | String interpolation in `where("...")` | Critical |
| 8 | **XSS / template output** | `grep -rn 'raw ' app/` | `raw` or `html_safe` on user input | Critical |
| 9 | **Session config** | Review `config.sessions` in `config/app.rb` | No secret, hardcoded secret, or no expiration | High |
| 10 | **Error messages** | Review auth failure responses | Messages like "User not found" or "Password incorrect" (user enumeration) | Advisory |

### Completion Checkpoint

After completing all steps, compile findings into a summary:
- **Critical** — Must be fixed before merge; these are exploitable vulnerabilities (SQL injection, missing auth, hardcoded secrets, missing CSRF, direct param use, XSS).
- **High** — Should be fixed soon; meaningful risk but harder to exploit directly (missing authz, sensitive logging, insecure session config).
- **Advisory** — Best-practice improvements with lower immediate risk (generic error messages, structural hardening).

For each finding, report: location (file + line), severity, what was found, and the recommended fix (see Core Rules).

---

## Core Rules

Detailed remediation patterns for each finding category.

1. **Validate all params** via the Params DSL:

   ```ruby
   # GOOD
   params do
     required(:email).value(:string, format?: /\A.+@.+\z/)
     required(:password).value(:string, min_size?: 8)
   end

   # BAD
   user_repo.create(request.params)
   ```

2. **Enable CSRF protection** for HTML endpoints:

   ```ruby
   # config/app.rb
   config.actions.csrf_protection = true
   ```

3. **Authenticate in Actions** using injected services:

   ```ruby
   include Deps["authentication"]
   before :authenticate!

   def authenticate!(request, response)
     halt 401 unless authentication.valid?(request)
   end
   ```

4. **Never log sensitive data**:

   ```ruby
   # GOOD
   logger.info("Login attempt: #{params[:email]}")
   # BAD: logger.info("Login: #{params[:email]}, password: #{params[:password]}")
   ```

5. **Store secrets in settings**, never in code:

   ```ruby
   # config/settings.rb
   setting :session_secret, constructor: Types::String
   ```
   ```bash
   # .env
   SESSION_SECRET=your-secret-here
   ```

6. **Prevent SQL injection** using ROM's query interface:

   ```ruby
   # GOOD: users.where(email: params[:email]).one
   # BAD:  users.where("email = '#{params[:email]}'").one
   ```

7. **Escape output in templates** — ERB auto-escapes by default; never use `raw` on user input:

   ```erb
   <!-- GOOD -->
   <p><%= user.bio %></p>
   ```

8. **Use secure session configuration**:

   ```ruby
   config.sessions = :cookie, {
     key: "my_app.session",
     secret: settings.session_secret,
     expire_after: 60 * 60 * 24 * 7
   }
   ```

9. **Return generic error messages** for auth failures:

   ```ruby
   # GOOD: halt 401, { error: "Invalid credentials" }.to_json
   # BAD:  halt 401, { error: "User not found" }.to_json
   ```

---

## Integration

| Related Skill | When to chain |
|---|---|
| **validate-params** | All params must be validated before use. |
| **handle-errors** | Error responses must not leak sensitive information. |
| **settings** | Secrets and configuration must use Settings, not hardcoded values. |
| **code-review** | Security review is part of every code review. |
| **setup-authentication** | For implementing auth strategies. |
| **security-review-process** *(from ruby-core-skills)* | OWASP checklist, Ruby-level security concerns. |
