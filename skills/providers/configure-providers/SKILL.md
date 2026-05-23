---
name: configure-providers
license: MIT
description: >
  Configures Hanami providers for external services, database connections,
  and application-wide components. Covers provider structure, settings
  integration, and boot lifecycle. Use when setting up a new provider,
  adding a service, or configuring ROM connections.
  Trigger words: provider, configure, ROM setup, external service, database
  connection, dry-system, boot, register component.
metadata:
  version: 1.0.0
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

## Extended Resources (Progressive Disclosure)

Load these files only when needed:

- **[PROVIDER_PATTERNS.md](./PROVIDER_PATTERNS.md)** — Common provider patterns: ROM connections, HTTP clients, background job adapters, cache stores.

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
