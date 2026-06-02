---
name: configure-slice
license: MIT
type: atomic
description: >
  Creates and configures Hanami 2.x Slices by registering providers, setting up container
  dependencies, customizing auto-registration paths, and managing slice-level settings.
  Use when configuring slice setup, modular app structure, Hanami component registration,
  dependency injection, provider registration, container imports/exports, or autoloading
  for a Hanami 2.x Slice.
metadata:
  ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
  tags:
  - slices
  - configuration
  - settings
  - providers
  version: 1.0.0
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

9. **Verify configuration after changes**. Run `bundle exec hanami console` and confirm components resolve correctly:

   ```ruby
   # Verify settings are loaded
   MyApp::Slices::Api::Slice[:settings].api_key  # => expected value

   # Verify a registered provider component is available
   MyApp::Slices::Api::Slice["api.client"]  # => #<ApiClient ...>

   # Verify an imported component resolves
   MyApp::Slices::Api::Slice["repositories.users"]  # => #<Repositories::Users ...>
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll duplicate main app configuration in every slice" | Slices inherit main app configuration. Only override when the slice genuinely needs different behavior. |
| "I'll forget to export components other slices depend on" | If Slice B imports from Slice A, Slice A must `export` those components. Verify with `Slice["component.key"]` in the console. |
| "I'll use `ENV` directly instead of slice settings" | Use `config.settings` for typed, validated configuration. Access via `target[:settings]`. |
| "I'll configure auto-registration to include ROM-managed directories" | Never auto-register `relations/`, `structs/`, or `entities/`. ROM manages these. |

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-slice** | Configuration follows slice creation. Understand slices before configuring. |
| **register-provider** | Slice-specific providers are registered in slice configuration. |
| **manage-settings** | Slice-level settings are defined in the Slice class. |
| **inject-dependencies** | Configured components are injected via `Deps[]`. |
| **create-new-slice** (workflow) | Full workflow includes configuration step. |
