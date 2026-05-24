---
name: validate-params
license: MIT
description: >
  Use when validating request parameters in Hanami 2.x Actions, including defining
  required/optional params blocks, applying type coercion (integer, bool, date), validating
  nested and array params, adding constraints, writing custom cross-field rules, and
  handling validation errors with 422 responses. Covers params block DSL, dry-validation
  predicates, input validation, action params, parameter types, and coercion of request
  input at the HTTP boundary.
metadata:
  ecosystem_sources:
  - hanami/hanami-controller
  tags:
  - actions
  - params
  - validation
  - input
  version: 1.0.0
---

# validate-params

Use this skill when validating and coercing request parameters in Hanami 2.x Actions.

**Core principle:** Params are validated at the boundary. Invalid input never reaches business logic.

---

## Validation Workflow

1. **Define `params` block** inside the Action class with required/optional fields and types
2. **Hanami validates automatically** — no manual trigger needed; invalid input halts with 422
3. **Check `request.params.errors`** — inspect or return errors if you need custom responses
4. **Proceed only if valid** — call business logic after confirming no errors

```ruby
def handle(request, response)
  # Step 3: check errors (optional — Hanami already halted if invalid)
  if request.params.errors.any?
    response.status = 422
    response.body = { errors: request.params.errors.to_h }.to_json
    return
  end

  # Step 4: proceed with validated, coerced params
  result = user_repo.create(request.params[:user])
  response.status = 201
  response.body = result.to_json
end
```

---

## Quick Reference (Syntax Cheat Sheet)

| Scenario | Syntax |
|---|---|
| Required param | `required(:email).value(:string)` |
| Optional param | `optional(:bio).value(:string)` |
| Integer coercion | `required(:age).value(:integer)` |
| Boolean coercion | `required(:active).value(:bool)` |
| Date coercion | `required(:birth_date).value(:date)` |
| Format constraint | `required(:email).value(:string, format?: /\A.+@.+\z/)` |
| Size constraints | `required(:name).value(:string, min_size?: 1, max_size?: 100)` |
| Numeric range | `required(:age).value(:integer, gt?: 0, lteq?: 120)` |
| Enum validation | `required(:role).value(:string, included_in?: %w[admin member guest])` |
| Nested params | `required(:user).hash { required(:name).value(:string) }` |
| Array param | `required(:tags).array(:string)` |
| Custom rule | `rule(:email) { key.failure("is invalid") unless value.include?("@") }` |
| Access param | `request.params[:key]` (returns coerced value) |
| Read errors | `request.params.errors.to_h` |

---

## Core Rules

1. **Define params inside the Action class**:

   ```ruby
   # app/actions/users/create.rb
   # frozen_string_literal: true

   module MyApp
     module Actions
       module Users
         class Create < MyApp::Action
           include Deps["repos.user_repo"]

           params do
             required(:user).hash do
               required(:email).value(:string, format?: /\A.+@.+\z/)
               required(:first_name).value(:string, min_size?: 1)
               required(:last_name).value(:string, min_size?: 1)
               optional(:bio).value(:string)
               optional(:role).value(:string, included_in?: %w[admin member guest])
             end
           end

           def handle(request, response)
             result = user_repo.create(request.params[:user])
             response.status = 201
             response.body = result.to_json
           end
         end
       end
     end
   end
   ```

2. **Custom rules** for cross-field validation:

   ```ruby
   params do
     required(:password).value(:string, min_size?: 8)
     required(:password_confirmation).value(:string)

     rule(:password_confirmation) do
       key.failure("must match password") unless value == values[:password]
     end
   end
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| Validating in the Repository instead of the Action | Params are validated at the HTTP boundary. Repositories receive already-validated data. |
| Accessing `request.params` without a `params` block | Without a `params` block, `request.params` is an untrusted hash. Always define the schema. |
| Putting business rules in the `params` block | Params validation checks shape and constraints. Business rules belong in interactors or service objects. |
| Duplicating params schemas across multiple Actions | Extract shared params to a module or base class if multiple Actions share the same input shape. |
| Complex nested params without hash/array declarations | Always use `.hash {}` and `.array()` for nested structures; untyped nesting is unsupported. |

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Params are defined inside Actions. Master Action structure first. |
| **handle-errors** | Invalid params trigger automatic halts. Handle errors gracefully. |
| **build-json-api** | JSON request bodies are parsed and validated through the Params DSL. |
| **handle-result-pattern** | Validated params are passed to interactors that return Success/Failure. |
