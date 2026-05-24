---
name: handle-result-pattern
license: MIT
description: >
  Use when using dry-monads Result pattern in Hanami 2.x. Covers Success/Failure wrapping,
  bind/fmap chaining, and use in service objects registered in the DI container.
metadata:
  ecosystem_sources:
  - dry-rb/dry-monads
  tags:
  - dry-monads
  - result
  - monads
  - service-objects
  version: 1.0.0
---

# handle-result-pattern

Use this skill when using the dry-monads Result pattern in Hanami 2.x.

**Core principle:** Explicitly model success and failure. Return `Success` or `Failure` from operations that can fail, then chain them with `bind` and `fmap`.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Wrap a success | `Success(value)` |
| Wrap a failure | `Failure(error_message)` or `Failure(error_object)` |
| Chain on success | `result.bind { \|value\| next_operation(value) }` |
| Transform success value | `result.fmap { \|value\| value.upcase }` |
| Handle failure | `result.or { \|error\| fallback_operation(error) }` |
| Extract value | `result.value!` (raises on Failure) |
| Check status | `result.success?` / `result.failure?` |
| Pattern match | `case result; in Success(v); ...; in Failure(e); ...; end` |

---

## Core Rules

1. **Use `dry-monads` in service objects** registered in the DI container:

   ```ruby
   # app/operations/create_user.rb
   # frozen_string_literal: true

   require "dry/monads"
   require "dry/monads/do"

   module MyApp
     module Operations
       class CreateUser
         include Dry::Monads[:result]
         include Dry::Monads::Do.for(:call)

         include Deps["repos.user_repo"]

         def call(attrs)
           validated = yield validate(attrs)
           user = yield create_user(validated)

           Success(user)
         end

         private

         def validate(attrs)
           return Failure("Email is required") if attrs[:email].nil? || attrs[:email].empty?
           return Failure("Name is required") if attrs[:first_name].nil? || attrs[:first_name].empty?

           Success(attrs)
         end

         def create_user(attrs)
           user = user_repo.create(attrs)
           Success(user)
         rescue StandardError => e
           Failure("Database error: #{e.message}")
         end
       end
     end
   end
   ```

2. **Register the service object** in the container:

   ```ruby
   # config/providers/operations.rb
   Hanami.app.register_provider(:operations) do
     start do
       register("operations.create_user", MyApp::Operations::CreateUser.new)
     end
   end
   ```

3. **Inject and call the service object** in an Action:

   ```ruby
   # app/actions/users/create.rb
   module MyApp
     module Actions
       module Users
         class Create < MyApp::Action
           include Deps["operations.create_user"]

           def handle(request, response)
             result = create_user.call(request.params[:user])

             case result
             in Dry::Monads::Success(user)
               response.status = 201
               response.body = user.to_json
             in Dry::Monads::Failure(error)
               response.status = 422
               response.body = { error: error }.to_json
             end
           end
         end
       end
     end
   end
   ```

4. **Chain operations** with `bind`:

   ```ruby
   result = validate_params(params)
  result.bind { |valid|
    find_user(valid[:id]).bind { |user|
      update_user(user, valid[:attrs])
    }
  }.fmap { |user| format_user(user) }
   ```

5. **Use `Do notation`** for sequential operations:

   ```ruby
   def call(attrs)
     validated = yield validate(attrs)
     user = yield create_user(validated)
     notify = yield send_welcome_email(user)

     Success(user)
   end
   ```

6. **Model failures as data**, not exceptions:

   ```ruby
   # GOOD: Return Failure with structured error
   Failure({ code: :email_taken, message: "Email already registered" })

   # BAD: Raise exception for expected failures
   raise EmailTakenError, "Email already registered"
   ```

7. **Keep service objects focused**. One operation = one class. Do not create monolithic operation classes.

---

## Common Mistakes & Red Flags

Reviewers and developers should check for these patterns:
- [ ] Raising exceptions for expected domain errors (validation, resource missing). Use `Failure` instead.
- [ ] Unsafely unwrapping monadic Results with `value!` without verifying status. Use pattern matching (`in Success(v)`) or flow-based chains (`bind`/`fmap`).
- [ ] Putting business logic in HTTP Actions instead of service objects.
- [ ] Forgetting to register service objects/operations in the DI container.
- [ ] Returning ambiguous `nil` or `false` values instead of explicit `Success` or `Failure`.
- [ ] Writing deeply nested `bind` blocks. Use `Do` notation (`yield`) to flatten sequential operations.
- [ ] Creating monolithic service objects doing multiple unrelated tasks.

---

## Integration

| Related Skill | When to chain |
|---|---|
| **inject-dependencies** | Service objects are injected into Actions via `Deps[]`. |
| **create-action** | Actions call service objects and handle `Success`/`Failure`. |
| **handle-errors** | `Failure` results map to HTTP error responses (422, 404, etc.). |
| **validation-contract** | Validation results are often `Success`/`Failure` from dry-validation. |
| **refactor-code** | Extract business logic from Actions into `Success`/`Failure` service objects. |

---

## Rails → Hanami Reference

For developers transitioning from Rails/ActiveRecord exception patterns, see the side-by-side [RAILS_COMPARISON.md](RAILS_COMPARISON.md) guide.
