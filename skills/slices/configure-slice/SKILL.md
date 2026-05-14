---
name: configure-slice
version: "1.0.0"
license: MIT
description: >
  Use when configuring Hanami 2.x Slices. Covers slice-level settings, providers,
  container configuration, and custom slice behavior.
ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
tags:
  - slices
  - configuration
  - settings
  - providers
---

# configure-slice

Use this skill when configuring Hanami 2.x Slices.

**Core principle:** Each Slice configures its own container, settings, and providers independently of the main app.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Configure a Slice | Edit `slices/<name>/config/slice.rb` |
| Define slice-level settings | Use `config.settings` in the Slice class |
| Register slice providers | Use `register_provider` in the Slice class |
| Configure auto-registration | Set `config.auto_register_paths` |
| Exclude paths from auto-registration | Set `config.no_auto_register_paths` |
| Access slice settings | `target[:settings]` in providers or `slice.settings` |
| Override main app config | Define config in the Slice that takes precedence |
| Container imports | `import from: :other_slice` |
| Container exports | `export ["component.key"]` |

---

## Core Rules

1. **Create the Slice configuration file**:

   ```ruby
   # slices/api/config/slice.rb
   # frozen_string_literal: true

   module MyApp
     module Slices
       module Api
         class Slice < Hanami::Slice
           # Slice-level configuration
         end
       end
     end
   end
   ```

2. **Define slice-level settings**:

   ```ruby
   class Slice < Hanami::Slice
     config.settings do
       setting :api_key, constructor: Types::String
       setting :rate_limit, default: 100, constructor: Types::Integer
     end
   end
   ```

3. **Register slice-specific providers**:

   ```ruby
   class Slice < Hanami::Slice
     register_provider(:api_client) do
       start do
         client = ApiClient.new(
           api_key: target[:settings].api_key,
           base_url: "https://api.example.com"
         )
         register("api.client", client)
       end
     end
   end
   ```

4. **Configure auto-registration paths**:

   ```ruby
   class Slice < Hanami::Slice
     config.auto_register_paths = ["app/actions", "app/views", "app/repos"]
     config.no_auto_register_paths = ["app/relations", "app/structs", "app/entities"]
   end
   ```

5. **Import components from another Slice**:

   ```ruby
   class Slice < Hanami::Slice
     import from: :main do
       # Import all exported components from the main slice
     end
   end
   ```

6. **Export components for other slices**:

   ```ruby
   class Slice < Hanami::Slice
     export ["repositories.users", "services.auth"]
   end
   ```

7. **Override main app configuration** for slice-specific needs:

   ```ruby
   class Slice < Hanami::Slice
     # Use a different database for this slice
     config.database_url = target[:settings].database_url
   end
   ```

8. **Keep configuration minimal**. Only override defaults when necessary. Prefer convention over configuration.

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll duplicate main app configuration in every slice" | Slices inherit main app configuration. Only override when the slice genuinely needs different behavior. |
| "I'll define all providers in the main app" | Slice-specific providers (e.g., API client) should live in the slice configuration. |
| "I'll forget to export components other slices depend on" | If Slice B imports from Slice A, Slice A must `export` those components. |
| "I'll use `ENV` directly instead of slice settings" | Use `config.settings` for typed, validated configuration. Access via `target[:settings]`. |
| "I'll configure auto-registration to include ROM-managed directories" | Never auto-register `relations/`, `structs/`, or `entities/`. ROM manages these. |
| "I'll create tight coupling by importing everything from another slice" | Import only what you need. Explicit imports make dependencies visible. |

---

## Red Flags

- Duplicated configuration across slices
- All providers defined in the main app
- Missing exports for imported components
- Direct `ENV` access instead of settings
- ROM-managed directories in auto-registration
- Overly broad imports (`import from: :all`)
- Slice configuration that violates bounded context boundaries

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-slice** | Configuration follows slice creation. Understand slices before configuring. |
| **register-provider** | Slice-specific providers are registered in slice configuration. |
| **manage-settings** | Slice-level settings are defined in the Slice class. |
| **inject-dependencies** | Configured components are injected via `Deps[]`. |
| **create-new-slice** (workflow) | Full workflow includes configuration step. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Slice Configuration) |
|---|---|
| `config/initializers` (app-wide) | `config/app.rb` (main app) + `slices/<name>/config/slice.rb` (per slice) |
| `MyEngine::Engine.config` | `MyApp::Slices::Api::Slice.config` |
| `isolate_namespace` | Natural namespace under `MyApp::Slices::Name` |
| Engine-specific settings | `config.settings` in Slice class |
| `config.autoload_paths` | `config.auto_register_paths` in Slice class |
| Engine-specific database | `config.database_url` in Slice class |
