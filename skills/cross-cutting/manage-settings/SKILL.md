---
name: manage-settings
version: "1.0.0"
license: MIT
description: >
  Use when managing Hanami 2.x application settings. Covers typed environment
  variable declaration with dry-configurable and accessing settings in components.
ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
tags:
  - configuration
  - settings
  - environment
  - dry-configurable
---

# manage-settings

Use this skill when managing Hanami 2.x application settings.

**Core principle:** Settings are typed, validated, and loaded from environment variables. They are the single source of truth for configuration.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Define a setting | `setting :database_url, constructor: Types::String` |
| Define with default | `setting :port, default: 2300, constructor: Types::Integer` |
| Define optional setting | `setting :api_key, constructor: Types::String.optional` |
| Access in Action | `Hanami.app[:settings].database_url` |
| Access in provider | `target[:settings].database_url` |
| Environment variable | `DATABASE_URL=postgres://...` |
| Required setting | Omit `default:` — missing env var raises at boot |
| Type coercion | `constructor: Types::Integer` coerces `"2300"` → `2300` |

---

## Core Rules

1. **Define settings in `config/settings.rb`**:

   ```ruby
   # config/settings.rb
   # frozen_string_literal: true

   module MyApp
     class Settings < Hanami::Settings
       setting :database_url, constructor: Types::String
       setting :port, default: 2300, constructor: Types::Integer
       setting :host, default: "localhost", constructor: Types::String
       setting :session_secret, constructor: Types::String
       setting :api_key, constructor: Types::String.optional
       setting :log_level, default: "info", constructor: Types::String.enum("debug", "info", "warn", "error")
     end
   end
   ```

2. **Settings map to environment variables** with UPPER_SNAKE_CASE:

   | Setting | Environment Variable |
   |---|---|
   | `database_url` | `DATABASE_URL` |
   | `port` | `PORT` |
   | `session_secret` | `SESSION_SECRET` |
   | `api_key` | `API_KEY` |

3. **Access settings** in components:

   ```ruby
   # In an Action
   Hanami.app[:settings].database_url

   # In a provider
   target[:settings].session_secret

   # In a service object (injected)
   include Deps["settings"]
   settings.database_url
   ```

4. **Required settings** (no default) raise at boot if missing:

   ```ruby
   setting :database_url, constructor: Types::String
   # Raises if DATABASE_URL is not set
   ```

5. **Optional settings** use `Types::String.optional`:

   ```ruby
   setting :api_key, constructor: Types::String.optional
   # nil if API_KEY is not set
   ```

6. **Type coercion** happens automatically:

   ```ruby
   setting :port, default: 2300, constructor: Types::Integer
   # PORT="8080" → 8080 (Integer)
   ```

7. **Enum validation** restricts allowed values:

   ```ruby
   setting :log_level, default: "info", constructor: Types::String.enum("debug", "info", "warn", "error")
   # Raises if LOG_LEVEL="verbose" (not in enum)
   ```

8. **Slice-level settings** override or extend app settings:

   ```ruby
   # slices/api/config/slice.rb
   class Slice < Hanami::Slice
     config.settings do
       setting :api_key, constructor: Types::String
     end
   end
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll access `ENV` directly instead of using settings" | Always use `Hanami.app[:settings]`. Settings are typed, validated, and testable. |
| "I'll define settings in `config/app.rb`" | Settings belong in `config/settings.rb` or slice-level `config/settings.rb`. |
| "I'll forget to set required environment variables" | Required settings (no default) raise at boot. Document all required vars in `.env.example`. |
| "I'll use `Types::String` for numeric values" | Use `Types::Integer` or `Types::Float` for numeric settings to get automatic coercion. |
| "I'll define secrets as optional settings" | Secrets (`session_secret`, `api_key`) should be required in production. Use defaults only for development. |
| "I'll access settings in Views or templates" | Settings are for configuration. Pass configuration-derived values as exposures from Actions. |

---

## Red Flags

- Direct `ENV` access in components
- Settings defined outside `config/settings.rb`
- Missing required environment variables in production
- Untyped settings (all `Types::String`)
- Secrets as optional settings
- Settings accessed in Views or templates
- Hardcoded configuration values outside settings

---

## Integration

| Related Skill | When to chain |
|---|---|
| **register-provider** | Providers read settings via `target[:settings]`. Define settings before writing providers. |
| **inject-dependencies** | Settings can be injected via `Deps["settings"]`. |
| **configure-slice** | Slices can define their own settings. |
| **create-app** | Generated apps include `config/settings.rb`. Define settings after scaffolding. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Settings) |
|---|---|
| `ENV["DATABASE_URL"]` | `Hanami.app[:settings].database_url` |
| `Rails.application.config` | `Hanami.app[:settings]` |
| `config/database.yml` | `DATABASE_URL` environment variable + `config/settings.rb` |
| `Rails.application.credentials` | Settings with `constructor: Types::String` (or use a dedicated secrets provider) |
| `config/environments/development.rb` | `config/settings.rb` with defaults + `HANAMI_ENV` |
| `dotenv-rails` gem | Built-in support for `.env` files (via `dotenv` gem) |
