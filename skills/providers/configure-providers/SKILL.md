---
name: configure-providers
license: MIT
description: >
  Configure Hanami providers at `config/providers/[name].rb` using `Hanami.app.register_provider(:name) do [...] end` — define settings in `config/settings.rb` if the service needs configuration, implement lifecycle with `prepare` for requiring gems and `start` for instantiation using `target["settings"]` to access config (never hardcode credentials or use raw ENV), register with a descriptive key via `register("key", instance)`, and verify the provider boots without errors. Covers provider structure, settings integration, and boot lifecycle. Use when setting up a new provider, adding a service, or configuring ROM connections.
  Trigger words: provider, configure, ROM setup, external service, database
  connection, dry-system, boot, register component.
metadata:
  version: "1.0.0"
  user-invocable: "true"
---
# Configuring Hanami Providers

Set up providers for services, databases, and application components following Hanami conventions.

## Quick Reference

- **Location:** `config/providers/<name>.rb`
- **Structure:** `Hanami.app.register_provider(:name) do ... end`
- **Lifecycle:** `prepare` (lazy) → `start` (eager, on first use or boot)
- **Rule:** Every external service gets a provider. Settings go through `target["settings"]`.

## HARD-GATE

```text
DO NOT hardcode credentials, URLs, or API keys in providers.
DO NOT call the container directly outside of providers.
DO use settings for all environment-dependent configuration.
```

## Core Process

1. **Identify the dependency** — external service, database, or application component.
2. **Define settings** in `config/settings.rb` if the service needs configuration:
   ```ruby
   setting :redis_url, constructor: Types::String
   ```
3. **Create the provider** at `config/providers/<name>.rb`:
   ```ruby
   Hanami.app.register_provider(:redis) do
     prepare do
       require "redis"
     end

     start do
       url = target["settings"].redis_url
       client = Redis.new(url:)
       register("redis", client)
     end
   end
   ```
4. **Use `prepare`** for requiring gems and lightweight setup.
5. **Use `start`** for instantiation and registration. Access other registered components via `target[...]`.
6. **Register with a descriptive key** — `"redis"`, `"http_client"`, not generic names.
7. **Verify** — ensure the provider boots without errors. If it needs external resources (database, API), handle connection failures gracefully.

## Common Provider Patterns

Apply these patterns for frequently encountered service types:

- **ROM/database connection** — register the ROM container in `start`; use `target["settings"]` for the database URL; depend on the `:persistence` provider in consumers.
- **HTTP client** — require the HTTP library in `prepare`; instantiate with base URL and headers from settings in `start`; register as `"http_client"` or a service-specific key.
- **Background job adapter** — configure the adapter class and queue connection in `start`; register as `"jobs.adapter"` so job classes can resolve it via `Deps`.
- **Cache store** — require the cache library in `prepare`; build the store with TTL and connection settings from `target["settings"]` in `start`.

> If a `PROVIDER_PATTERNS.md` file is present in the bundle, load it for extended code examples for the above patterns.

## Output Style

1. **Provider file** — the complete `config/providers/<name>.rb` content.
2. **Settings additions** — any new settings needed in `config/settings.rb`.
3. **Registration key** — the key used to register the component.
4. **Injection usage** — how to use `include Deps["<key>"]` in consumers.
5. **Verification** — how to confirm the provider boots correctly.
6. **English only** unless user requests otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **load-context** | Always first — discover existing providers before adding new ones |
| **implement-di** | After provider setup, to configure injection in consumers |
| **hanami-setup** | Part of the project onboarding workflow |
