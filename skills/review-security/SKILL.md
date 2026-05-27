---
name: review-security
license: MIT
description: >
  Use when conducting a security audit on Hanami 2.x applications — validate params via the Params DSL in every Action, verify CSRF protection is enabled in config/app.rb, audit authentication checks via explicit `before :authenticate!`, check authorization with role/permission checks, never log passwords/tokens/secrets, use ROM query interface to prevent SQL injection (no string interpolation in `where("...")`), never use `raw` on user input in templates, store secrets in settings not hardcoded, and return generic error messages for auth failures. Validates parameter handling, CSRF, auth integration, XSS, and session configuration.
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

Follow this sequence when performing a security review:

1. **Validate params** — Check every Action for a `params` block. Grep: `grep -rn 'request.params' app/actions/ | grep -v 'params do'`
2. **Verify CSRF config** — Confirm `config.actions.csrf_protection = true` in `config/app.rb` for HTML apps.
3. **Audit auth checks** — Confirm every sensitive Action has an explicit `before :authenticate!` or equivalent. Grep: `grep -rn 'def handle' app/actions/` and cross-check with `grep -rn 'authenticate'`
4. **Check authorization** — Confirm role/permission checks exist in Actions or service objects beyond mere authentication.
5. **Scan for secrets in code** — Grep: `grep -rn 'secret\|password\|api_key\|token' app/ config/ --include='*.rb' | grep -v 'settings\|ENV'`
6. **Check logging** — Grep: `grep -rn 'logger' app/ | grep 'password\|token\|secret'`
7. **Check SQL safety** — Grep: `grep -rn 'where("' app/` to find potential string interpolation in queries.
8. **Check template output** — Grep: `grep -rn 'raw ' app/` to find unescaped output.
9. **Review session config** — Confirm `config.sessions` has a secret from settings, not hardcoded.
10. **Review error messages** — Confirm auth failures return generic messages (no user enumeration).

---

## Quick Reference Checklist

| Concern | Red Flag |
|---|---|
| Param validation | `request.params` used directly in business logic |
| CSRF protection | Missing `csrf_protection = true` for HTML endpoints |
| Authentication | Auth assumed by convention, not explicit check |
| Authorization | Only authn, no authz |
| Error messages | Messages like "User not found" or "Password incorrect" |
| Logging | `params[:password]` or tokens in log calls |
| Secrets | Hardcoded strings for keys/secrets in source files |
| SQL injection | String interpolation in `where("...")` |
| XSS | `raw` or `html_safe` on user input |
| Session management | No secret, no expiration, or hardcoded secret |

---

## Core Rules

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
