---
name: register-provider
version: "1.0.0"
license: MIT
description: >
  Use when registering external dependencies in Hanami 2.x. Covers provider
  registration in config/providers/, database, mailer, cache, and third-party services.
ecosystem_sources:
  - dry-rb/dry-system
  - hanami/hanami
tags:
  - di
  - providers
  - container
  - external-services
---

# register-provider

Use this skill when registering external dependencies (database, mailer, cache, third-party APIs) in the Hanami 2.x DI container.

**Core principle:** Providers bridge external libraries into the DI container. They handle initialization, configuration, and lifecycle.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Create a provider | `bundle exec hanami generate provider <name>` |
| Register a database | Use the built-in `database` provider or custom provider |
| Register a mailer | Create `config/providers/mailer.rb` |
| Register a cache | Create `config/providers/cache.rb` |
| Register a third-party API client | Create `config/providers/<service>.rb` |
| Access the provided component | `include Deps["<provider_name>.<component>"]` |
| Configure the provider | Use the `prepare` and `start` lifecycle hooks |

---

## Core Rules

1. **Generate a provider** using the Hanami CLI:

   ```bash
   hanami generate provider mailer
   ```

   This creates `config/providers/mailer.rb`.

2. **Implement the provider** with `prepare` and `start` hooks:

   ```ruby
   # config/providers/mailer.rb
   # frozen_string_literal: true

   Hanami.app.register_provider(:mailer) do
     prepare do
       # Configuration that runs before the app boots
       require "mail"
     end

     start do
       # Initialization that runs when the component is first accessed
       client = Mail.new do
         delivery_method :smtp, {
           address: target[:settings].smtp_host,
           port: target[:settings].smtp_port
         }
       end

       register("mailer.client", client)
     end
   end
   ```

3. **Access provided components** via `Deps`:

   ```ruby
   # app/mailers/welcome.rb
   # frozen_string_literal: true

   module MyApp
     module Mailers
       class Welcome
         include Deps["mailer.client"]

         def deliver(user)
           client.deliver do
             to user.email
             from "noreply@example.com"
             subject "Welcome!"
             body "Welcome to MyApp, #{user.first_name}!"
           end
         end
       end
     end
   end
   ```

4. **Use the built-in database provider** (already configured by Hanami):

   ```ruby
   # Access the ROM container
   include Deps["db.rom"]

   # Access a specific gateway
   include Deps["db.gateway"]
   ```

5. **Register third-party API clients** as providers:

   ```ruby
   # config/providers/stripe.rb
   # frozen_string_literal: true

   Hanami.app.register_provider(:stripe) do
     start do
       require "stripe"
       Stripe.api_key = target[:settings].stripe_secret_key
       register("stripe.client", Stripe)
     end
   end
   ```

6. **Keep providers focused**. One external service = one provider. Do not create a monolithic provider.

7. **Use `target[:settings]`** to access application settings within providers:

   ```ruby
   start do
     api_key = target[:settings].some_api_key
     register("service.client", SomeService.new(api_key: api_key))
   end
   ```

8. **Test components that depend on providers** by stubbing the provided dependency:

   ```ruby
   stub_mailer = double("mailer", deliver: true)
   welcome = MyApp::Mailers::Welcome.new(mailer__client: stub_mailer)
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll initialize external clients directly in Actions" | Always register external services as providers. Direct initialization is untestable and scatters configuration. |
| "I'll create one provider for all external services" | One provider per external service. Monolithic providers are hard to test and reason about. |
| "I'll access `ENV` directly in the provider" | Use `target[:settings]` for configuration. Settings are typed and validated. |
| "I'll skip the `prepare` hook and put everything in `start`" | Use `prepare` for requiring libraries. Use `start` for initialization. This keeps boot fast. |
| "I'll forget to handle initialization errors in the provider" | Rescue and log errors in `start`. A failed provider should not crash the app boot. |
| "I'll register components with inconsistent naming" | Use `register("provider_name.component_name", instance)` consistently. Match the key to the file path convention. |

---

## Red Flags

- External clients initialized in Actions or Views
- Monolithic providers handling multiple unrelated services
- Direct `ENV` access in providers
- Missing `prepare` / `start` separation
- Unhandled initialization errors that crash boot
- Inconsistent naming of registered components
- Providers that contain business logic

---

## Integration

| Related Skill | When to chain |
|---|---|
| **inject-dependencies** | Provided components are injected via `Deps[]`. Understand `Deps` before writing providers. |
| **manage-settings** | Providers read configuration from `target[:settings]`. Define settings before writing providers. |
| **create-action** | Actions inject provided services via `Deps[]`. |
| **create-repository** | The database provider registers ROM, which Repositories depend on. |
| **integrate-api-client** | Complex API clients may need a dedicated skill for auth/patterns. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Providers) |
|---|---|
| `config/initializers/mailer.rb` | `config/providers/mailer.rb` with `prepare` and `start` hooks |
| `Rails.application.config.action_mailer.*` | `target[:settings]` accessed in provider `start` block |
| `Stripe.api_key = ENV['STRIPE_KEY']` | Provider `start` block with `target[:settings].stripe_secret_key` |
| `config/initializers/*.rb` (eager load) | `prepare` hook (require libraries) + `start` hook (initialize lazily) |
| `Rails.cache` | Register a cache provider, inject via `Deps["cache.client"]` |
