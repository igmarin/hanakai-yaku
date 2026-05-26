---
name: implement-di
license: MIT
description: >
  Inject dependencies through the constructor using Hanami's `auto_inject` and `Deps["provider_key"]` — never call `Hanami.app["key"]` outside of providers, dependencies must be registered by a provider first, pass `instance_double` test doubles through the constructor in specs, and validate key resolution to avoid `Dry::Container::Error` on unregistered keys. Covers constructor injection, and
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
5. **Validate resolution** — after adding the injection, confirm the key resolves correctly:
   ```bash
   bundle exec hanami console
   # Then in the console:
   # Hanami.app["operations.users.create_user"]  # should return the registered object
   ```
   If the key is unregistered, dry-system raises `Dry::Container::Error: Nothing registered with the key`. Check that the provider file exists, the key matches exactly (dot-namespaced, snake_case), and `auto_registration` covers the file path.
6. **Test with stubs** — inject test doubles through the constructor:
   ```ruby
   RSpec.describe Api::Actions::Users::Create do
     let(:create_user) { instance_double(Users::CreateUser, call: Dry::Monads::Success(user)) }
     # Pass each dep as a keyword arg; use instance_double (not double) so RSpec
     # validates the method exists on the real class.
     # For failure paths, return Dry::Monads::Failure(...) to test error branches.
     # For multiple deps: described_class.new(repo:, notifier:)
     let(:action) { described_class.new(create_user:) }

     it "calls the operation with request params" do
       result = action.call({ "user" => { "email" => "test@example.com" } })
       expect(create_user).to have_received(:call).with(hash_including("user"))
     end
   end
   ```

## Integration

| Skill | When to chain |
|-------|---------------|
| **configure-providers** | Register the dependency before injecting it |
| **load-context** | Discover existing DI conventions before adding new ones |
| **hanami-setup** | Part of the project onboarding workflow |
