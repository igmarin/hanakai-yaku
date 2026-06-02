---
name: register-provider
license: MIT
type: atomic
description: >
  Use when registering external dependencies in Hanami 2.x — integrating a gem, wiring up a service, or setting up dependency injection for databases, mailers, caches, and third-party APIs. Creates provider files at `config/providers/[name].rb` using `hanami generate provider [name]`, implements lifecycle hooks with `prepare` for requiring gems and `start` for instantiation and service registration, registers components with a descriptive key using `register("name.client", instance)`, always loads configuration through `target[:settings]` never raw `ENV`, rescues and logs errors in `start` to prevent boot crashes, and verifies registration via `Hanami.app["key"]` in console or a lightweight smoke test.
metadata:
  version: "1.0.0"
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

---

## Core Rules

1. **Generate a provider** using the Hanami CLI:

   ```bash
   hanami generate provider mailer
   ```

   This creates `config/providers/mailer.rb`.

2. **Implement the provider** using lifecycle hooks:
   Use `prepare` for requiring dependencies and `start` for component initialization. Keep providers focused on a single external dependency or library.

   ```ruby
   # config/providers/mailer.rb
   # frozen_string_literal: true

   Hanami.app.register_provider(:mailer) do
     prepare do
       require "mail"
     end

     start do
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

   > **Validation checkpoint:** After implementing the provider, verify it loads correctly before writing consuming code:
   > ```ruby
   > # In `hanami console`
   > Hanami.app["mailer.client"]   # => should return the registered instance without errors
   > ```
   > If this raises or returns `nil`, fix the provider before proceeding.

3. **Access provided components** via `Deps`:

   ```ruby
   # app/mailers/welcome.rb
   module MyApp
     module Mailers
       class Welcome
         include Deps["mailer.client"]

         def deliver(user)
           client.deliver do
             to user.email
             subject "Welcome!"
           end
         end
       end
     end
   end
   ```

4. **Use the built-in database provider**:
   The ROM container is automatically registered at boot by the framework:

   ```ruby
   include Deps["db.rom"]
   ```

5. **Register third-party API clients using settings**:
   Always load keys and URLs through `target[:settings]`. Do not reference raw environment variables via `ENV` in providers.

6. **Rescue and log errors in `start`** to control boot failure behavior. Choose one of two strategies:

   - **Swallow the error** (register a null/fallback object) if the service is optional and the app should still boot without it.
   - **Re-raise the error** if the service is required and a missing provider should halt boot.

   ```ruby
   # config/providers/storage.rb
   Hanami.app.register_provider(:storage) do
     prepare do
       require "aws-sdk-s3"
     end

     start do
       client = Aws::S3::Client.new(
         access_key_id: [REDACTED:API key param],
         secret_access_key: target[:settings].cloud_storage_secret,
         region: target[:settings].cloud_storage_region
       )
       register("storage.client", client)
     rescue StandardError => e
       target[:logger].error("[provider:storage] failed to start: #{e.message}")
       # Re-raise if this provider is required for the app to function:
       raise
       # Or register a null object and swallow if the service is optional:
       # register("storage.client", NullStorageClient.new)
     end
   end
   ```

7. **Test components that depend on providers** by stubbing the provided dependency:

   ```ruby
   stub_mailer = double("mailer", deliver: true)
   welcome = MyApp::Mailers::Welcome.new(mailer__client: stub_mailer)
   ```

8. **Verify a provider is correctly registered** using the Hanami console or a smoke test:

   ```ruby
   # In `hanami console`
   Hanami.app["mailer.client"]   # => returns the registered instance
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
