---
name: setup-authentication
license: MIT
description: >
  Use when implementing authentication in Hanami 2.x, including login, logout, signup, session
  management, password hashing, and protecting endpoints. Sets up login/logout flows, configures
  session-based or token-based auth, adds password hashing with bcrypt, and returns correct 401/403
  responses for auth failures. Use when a user asks about auth, login, signup, JWT, sessions,
  passwords, or securing Hanami actions.
metadata:
  ecosystem_sources:
  - hanami/hanami
  - hanami/hanami-controller
  tags:
  - agents
  - authentication
  - auth
  - security
  version: 1.0.0
---

# setup-authentication

Use this workflow when implementing authentication in Hanami 2.x.

**Core principle:** Authentication is explicit in every Action. No global magic — each Action declares its auth requirements.

---

## Workflow

### Step 1 — Inject Auth Service (`inject-dependencies`)

- Create an authentication service object
- Register it in the DI container
- Inject it into Actions that need auth
- **Handoff condition:** Auth service accessible via `Deps["authentication"]`

### Step 2 — Register Provider (`register-provider`)

- Create `config/providers/authentication.rb`
- Register the auth service in the `start` block
- **Handoff condition:** Auth service registered and injectable

**Example — `config/providers/authentication.rb`:**
```ruby
Hanami.app.register_provider(:authentication) do
  start do
    require "bcrypt"

    register("authentication", MyApp::Authentication::Service.new)
  end
end
```

### Step 3 — Create Actions (`create-action`)

- Create login Action: validates credentials, sets session/token
- Create logout Action: clears session/token
- Create protected Actions: check auth before processing
- **Handoff condition:** Login/logout work, protected endpoints require auth

**Example — minimal auth service:**
```ruby
# app/authentication/service.rb
module MyApp
  module Authentication
    class Service
      def authenticate(email:, password:, session:)
        user = UserRepository.new.find_by_email(email)
        return false unless user
        return false unless BCrypt::Password.new(user.password_digest) == password

        session[:user_id] = user.id
        true
      end

      def current_user(session)
        return nil unless session[:user_id]

        UserRepository.new.find(session[:user_id])
      end

      def authenticated?(session)
        !current_user(session).nil?
      end
    end
  end
end
```

**Example — login Action:**
```ruby
# app/actions/sessions/create.rb
module MyApp
  module Actions
    module Sessions
      class Create < MyApp::Action
        include Deps["authentication"]

        params do
          required(:email).filled(:string)
          required(:password).filled(:string)
        end

        def handle(request, response)
          halt 422 unless request.params.valid?

          authenticated = authentication.authenticate(
            email: request.params[:email],
            password: request.params[:password],
            session: request.session
          )

          if authenticated
            response.redirect_to "/dashboard"
          else
            response.status = 401
            response.body = { error: "Invalid credentials" }.to_json
          end
        end
      end
    end
  end
end
```

**Example — protected Action:**
```ruby
# app/actions/dashboard/show.rb
module MyApp
  module Actions
    module Dashboard
      class Show < MyApp::Action
        include Deps["authentication"]

        def handle(request, response)
          halt 401 unless authentication.authenticated?(request.session)

          user = authentication.current_user(request.session)
          response.body = { user: user.email }.to_json
        end
      end
    end
  end
end
```

### Step 4 — Handle Errors (`handle-errors`)

- Return 401 for missing/invalid credentials
- Return 403 for insufficient permissions
- Log auth failures (but not passwords)
- **Handoff condition:** Correct error responses for auth failures

---

## Verification

After each step, verify the workflow is progressing correctly:

```bash
# Verify provider is registered
bundle exec hanami console
> Hanami.app["authentication"]  # Should return auth service instance

# Test login endpoint
curl -X POST http://localhost:2300/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secret"}'
# Expect: redirect or 200 with session cookie on success; 401 on failure

# Test protected endpoint without auth
curl http://localhost:2300/dashboard
# Expect: 401 Unauthorized

# Test protected endpoint with session cookie
curl http://localhost:2300/dashboard --cookie "<session-cookie>"
# Expect: 200 with user data
```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll put auth in a base controller" | Hanami has no base controller. Each Action must explicitly check auth. |
| "I'll store passwords in plain text" | Always hash passwords with bcrypt or argon2. |
| "I'll skip session security configuration" | Configure secure sessions with `http_only`, `secure`, and `same_site`. |
| "I'll return specific error messages that reveal valid emails" | Return generic "Invalid credentials" for both missing user and wrong password. |
| Auth logic scattered across Actions | Centralise all auth logic in the auth service; Actions only call it. |
