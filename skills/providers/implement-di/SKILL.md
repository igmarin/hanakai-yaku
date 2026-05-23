---
name: implement-di
license: MIT
description: >
  Implements dependency injection patterns in Hanami using dry-system's
  auto_inject. Covers `include Deps[...]`, constructor injection, and
  testing with injected dependencies. Use when adding DI to actions,
  operations, or repositories.
  Trigger words: dependency injection, DI, auto_inject, Deps, inject,
  dry-system, constructor injection, test with DI.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Implementing Dependency Injection

Inject dependencies through the constructor using Hanami's `auto_inject` — never call the container directly.

## Quick Reference

- **Pattern:** `include Deps["provider_key"]` in actions, operations, or repositories.
- **Testing:** Pass test doubles through the constructor in specs.
- **Providers:** Dependencies must be registered by a provider first.
- **Rule:** Never call `Hanami.app["key"]` outside of providers.

## HARD-GATE

```text
DO NOT call the container directly (`Hanami.app["key"]`) outside of providers.
DO NOT use global state or class-level constants for dependencies.
DO inject dependencies through the constructor — use `include Deps[...]`.
```

## Core Process

1. **Verify the provider** — ensure the dependency is registered in a provider under a descriptive key.
2. **Add injection** in the consuming class:
   ```ruby
   module Api
     module Actions
       module Users
         class Create < Api::Action
           include Deps["operations.users.create_user"]

           def handle(req, res)
             result = create_user.call(req.params.to_h)
             # ...
           end
         end
       end
     end
   end
   ```
3. **For operations**, inject repositories and other operations:
   ```ruby
   module Users
     class CreateUser < Dry::Operation
       include Deps["repositories.user_repo", "operations.notifications.send_welcome"]

       def call(input)
         # ...
       end
     end
   end
   ```
4. **For repositories**, inject ROM if needed:
   ```ruby
   module Api
     module Repositories
       class UserRepo < ROM::Repository[:users]
         # Auto-injected if using auto_registration
       end
     end
   end
   ```
5. **Test with stubs** — inject test doubles through the constructor:
   ```ruby
   RSpec.describe Api::Actions::Users::Create do
     let(:create_user) { instance_double(Users::CreateUser, call: Dry::Monads::Success(user)) }
     let(:action) { described_class.new(create_user:) }
   end
   ```
   See [TESTING_DI.md](./TESTING_DI.md) for detailed testing patterns.

## Extended Resources (Progressive Disclosure)

Load these files only when needed:

- **[TESTING_DI.md](./TESTING_DI.md)** — Testing patterns for injected dependencies: stubs, mocks, contract verification.

## Output Style

1. **Class with DI** — the complete class with `include Deps[...]`.
2. **Provider key** — the exact key used for registration.
3. **Test example** — how to pass a test double through the constructor.
4. **English only** unless user requests otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **configure-providers** | Register the dependency before injecting it |
| **load-context** | Discover existing DI conventions before adding new ones |
| **hanami-setup** | Part of the project onboarding workflow |
