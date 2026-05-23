---
name: register-provider
version: "1.0.0"
license: MIT
description: >
  Use when registering external dependencies in Hanami 2.x. Creates provider
  files in config/providers/, configures dependency injection containers, sets
  up boot sequences with prepare/start lifecycle hooks, and integrates database,
  mailer, cache, and third-party services into the DI container.
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

   > ⚠️ Use `prepare` for requiring libraries only. Use `start` for initialization. Putting everything in `start` slows boot.

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

   > ⚠️ Never access `ENV` directly in providers. Use `target[:settings]` — settings are typed and validated.

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

9. **Verify a provider is correctly registered** using the Hanami console or a smoke test:

   > ⚠️ Rescue and log errors in `start`. A failed provider should not crash the app boot.

   ```ruby
   # In `hanami console`
   Hanami.app["mailer.client"]   # => returns the registered instance
   Hanami.app["stripe.client"]   # => returns Stripe
   ```

   For a lightweight smoke test in specs:

   ```ruby
   it "registers the mailer client" do
     expect(Hanami.app["mailer.client"]).to be_a(Mail::Message)
   end
   ```

---

## Integration

| Related Skill | When to chain |
|---|---|
| **inject-dependencies** | Provided components are injected via `Deps[]`. Understand `Deps` before writing providers. |
| **manage-settings** | Providers read configuration from `target[:settings]`. Define settings before writing providers. |
| **create-action** | Actions inject provided services via `Deps[]`. |
| **create-repository** | The database provider registers ROM, which Repositories depend on. |
| **integrate-api-client** | Complex API clients may need a dedicated skill for auth/patterns. |
