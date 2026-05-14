---
name: review-security
version: "1.0.0"
license: MIT
description: >
  Use when reviewing Hanami 2.x code for security. Covers param validation,
  CSRF protection, authentication integration points, and common vulnerabilities.
ecosystem_sources:
  - hanami/hanami
tags:
  - security
  - review
  - csrf
  - authentication
  - vulnerabilities
---

# review-security

Use this skill when reviewing Hanami 2.x code for security concerns.

**Core principle:** Security is layered. Validate at the boundary, authenticate explicitly, and never trust input.

---

## Quick Reference

| Concern | Check |
|---|---|
| Param validation | All params validated via Params DSL? No unvalidated input used? |
| CSRF protection | Enabled for HTML forms? Token validated? |
| Authentication | Action checks auth before processing? Identity injected via `Deps`? |
| Authorization | Role/permission checks in Action or service object? |
| Error messages | No sensitive data in error responses? |
| Logging | No passwords or tokens logged? |
| Secrets | Stored in settings/environment, not in code? |
| SQL injection | No string interpolation in queries? ROM/Sanitized only? |
| XSS | Output escaped in templates? No raw HTML from user input? |
| Session management | Secure session config? Session secret in settings? |

---

## Core Rules

1. **Validate all params** via the Params DSL:

   ```ruby
   # GOOD: All params validated and typed
   params do
     required(:email).value(:string, format?: /\A.+@.+\z/)
     required(:password).value(:string, min_size?: 8)
   end

   # BAD: Unvalidated params used directly
   def handle(request, response)
     user_repo.create(request.params)  # Dangerous!
   end
   ```

2. **Enable CSRF protection** for HTML endpoints:

   ```ruby
   # config/app.rb
   module MyApp
     class App < Hanami::App
       config.actions.csrf_protection = true
     end
   end
   ```

3. **Authenticate in Actions** using injected services:

   ```ruby
   class Create < MyApp::Action
     include Deps["authentication"]

     before :authenticate!

     def handle(request, response)
       # ... only reached if authenticated
     end

     private

     def authenticate!(request, response)
       halt 401 unless authentication.valid?(request)
     end
   end
   ```

4. **Never log sensitive data**:

   ```ruby
   # GOOD: Log sanitized data
   Hanami.app[:logger].info("User login attempt: #{params[:email]}")

   # BAD: Log sensitive data
   Hanami.app[:logger].info("User login: #{params[:email]}, password: #{params[:password]}")
   ```

5. **Store secrets in settings**, never in code:

   ```ruby
   # config/settings.rb
   setting :session_secret, constructor: Types::String
   setting :api_key, constructor: Types::String
   ```

   ```bash
   # .env
   SESSION_SECRET=your-secret-here
   API_KEY=your-api-key-here
   ```

6. **Prevent SQL injection** by using ROM's query interface:

   ```ruby
   # GOOD: ROM parameterized query
   users.where(email: params[:email]).one

   # BAD: String interpolation
   users.where("email = '#{params[:email]}'")  # SQL Injection risk!
   ```

7. **Escape output in templates** to prevent XSS:

   ```erb
   <!-- GOOD: ERB auto-escapes -->
   <p><%= user.bio %></p>

   <!-- BAD: raw HTML from user input -->
   <p><%= raw user.bio %></p>
   ```

8. **Use secure session configuration**:

   ```ruby
   # config/app.rb
   module MyApp
     class App < Hanami::App
       config.sessions = :cookie, {
         key: "my_app.session",
         secret: settings.session_secret,
         expire_after: 60 * 60 * 24 * 7  # 1 week
       }
     end
   end
   ```

9. **Return generic error messages** for security-sensitive failures:

   ```ruby
   # GOOD: Generic message prevents user enumeration
   halt 401, { error: "Invalid credentials" }.to_json

   # BAD: Specific message reveals valid users
   halt 401, { error: "User not found" }.to_json  # Reveals email is not registered
   halt 401, { error: "Password incorrect" }.to_json  # Reveals email is valid
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll skip param validation for internal endpoints" | Validate all params. Internal endpoints can be called externally. |
| "I'll disable CSRF for JSON APIs" | JSON APIs do not need CSRF tokens, but ensure `Content-Type: application/json` is enforced. |
| "I'll put auth logic in a base controller" | Hanami has no base controller. Each Action must explicitly handle auth. |
| "I'll log params for debugging" | Never log passwords, tokens, or session IDs. Sanitize logged data. |
| "I'll hardcode API keys for convenience" | All secrets belong in environment variables accessed via Settings. |
| "I'll use string interpolation in ROM queries" | Always use parameterized queries. ROM handles sanitization. |
| "I'll trust user input in HTML output" | ERB escapes by default. Never use `raw` or `html_safe` on user input. |

---

## Red Flags

- Unvalidated params used in business logic
- Missing CSRF protection for HTML forms
- Auth logic assumed by convention rather than explicit check
- Sensitive data in logs or error responses
- Secrets hardcoded in source files
- String interpolation in database queries
- `raw` or `html_safe` on user input
- Weak session configuration (no secret, no expiration)
- Specific error messages that reveal system state

---

## Integration

| Related Skill | When to chain |
|---|---|
| **validate-params** | All params must be validated before use. |
| **handle-errors** | Error responses must not leak sensitive information. |
| **settings** | Secrets and configuration must use Settings, not hardcoded values. |
| **code-review** | Security review is part of every code review. |
| **setup-authentication** | For implementing auth strategies. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Security) |
|---|---|
| `protect_from_forgery` | `config.actions.csrf_protection = true` |
| `before_action :authenticate_user!` | Explicit auth check in each Action (no global callbacks) |
| `strong_parameters` | Params DSL with type coercion and constraints |
| `Rails.logger` | `Hanami.app[:logger]` (sanitized logging) |
| `Rails.application.credentials` | Settings with environment variables |
| ActiveRecord parameterized queries | ROM parameterized queries (same principle) |
| `html_safe` | ERB auto-escapes; avoid `raw` |
| `config.session_store` | `config.sessions = :cookie, { ... }` in `config/app.rb` |
