---
name: manage-settings
license: MIT
description: >
  Use when managing Hanami 2.x application settings, app config, or environment variables
  (env vars). Covers defining typed settings with dry-configurable, setting defaults,
  validating enum values, reading .env files, and injecting settings into components
  via Hanami's container. Use when declaring typed environment variable declarations,
  accessing configuration in Actions or providers, or migrating from Rails config
  to Hanami 2.x settings.
metadata:
  ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
  tags:
  - configuration
  - settings
  - environment
  - dry-configurable
  version: 1.0.0
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
| Enum validation | `constructor: Types::String.enum("debug", "info", "warn")` |
| Access in Action | `Hanami.app[:settings].database_url` |
| Access in provider | `target[:settings].database_url` |
| Inject via Deps | `include Deps["settings"]` |
| Required setting | Omit `default:` — missing env var raises at boot |

---

## Workflow: Define → Configure → Access → Verify

### 1. Define settings in `config/settings.rb`

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

### 2. Set environment variables (UPPER_SNAKE_CASE)

| Setting | Environment Variable |
|---|---|
| `database_url` | `DATABASE_URL` |
| `port` | `PORT` |
| `session_secret` | `SESSION_SECRET` |
| `api_key` | `API_KEY` |

Use `.env` files for local development (supported via the `dotenv` gem).

### 3. Access settings in components

```ruby
# In an Action
Hanami.app[:settings].database_url

# In a provider
target[:settings].session_secret

# In a service object (injected)
include Deps["settings"]
settings.database_url
```

### 4. Verify settings load correctly

Boot the app with `hanami server` or `bundle exec hanami console` to confirm all required settings are present and correctly typed. Required settings (no `default:`) raise immediately at boot if the corresponding environment variable is missing — this is the intended failure mode.

```ruby
# Quick console check
bundle exec hanami console
Hanami.app[:settings].inspect
```

---

**Slice-level settings** override or extend app settings:

```ruby
# slices/api/config/slice.rb
class Slice < Hanami::Slice
  config.settings do
    setting :api_key, constructor: Types::String
  end
end
```

---

## Integration

| Related Skill | When to chain |
|---|---|
| **register-provider** | Providers read settings via `target[:settings]`. Define settings before writing providers. |
| **inject-dependencies** | Settings can be injected via `Deps["settings"]`. |
| **configure-slice** | Slices can define their own settings. |
| **create-app** | Generated apps include `config/settings.rb`. Define settings after scaffolding. |
