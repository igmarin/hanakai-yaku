---
name: action-params-validation
version: "1.0.0"
license: MIT
description: >
  Use when validating request parameters in Hanami 2.x Actions. Covers the Params
  DSL, validation rules, coercion, and error handling.
ecosystem_sources:
  - hanami/hanami-controller
tags:
  - actions
  - params
  - validation
  - input
---

# action-params-validation

Use this skill when validating and coercing request parameters in Hanami 2.x Actions.

**Core principle:** Params are validated at the boundary. Invalid input never reaches business logic.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Define params schema | Use the `params` block inside the Action class |
| Required param | `required(:email).value(:string)` |
| Optional param | `optional(:bio).value(:string)` |
| Nested params | `required(:user).hash { required(:name).value(:string) }` |
| Array param | `required(:tags).array(:string)` |
| Integer param | `required(:age).value(:integer)` |
| Boolean param | `required(:active).value(:bool)` |
| Date param | `required(:birth_date).value(:date)` |
| Enum validation | `required(:role).value(:string, included_in?: %w[admin member guest])` |
| Custom validation | `rule(:email) { key.failure("is invalid") unless value.include?("@") }` |
| Access validated params | `request.params[:key]` (returns coerced value) |
| Halt on validation failure | Invalid params automatically halt with 422; errors in `request.params.errors` |

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
             # Params are already validated and coerced here
             result = user_repo.create(request.params[:user])
             response.status = 201
             response.body = result.to_json
           end
         end
       end
     end
   end
   ```

2. **Use `required` for mandatory fields** and `optional` for optional ones:

   ```ruby
   params do
     required(:email).value(:string)
     optional(:phone).value(:string)
   end
   ```

3. **Specify types for coercion**. Hanami will coerce string inputs to the declared type:

   ```ruby
   required(:age).value(:integer)        # "25" → 25
   required(:active).value(:bool)       # "true" → true
   required(:score).value(:float)       # "3.14" → 3.14
   required(:birth_date).value(:date)    # "1990-01-01" → Date
   ```

4. **Add constraints** with predicates:

   ```ruby
   required(:email).value(:string, format?: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.\w+\z/)
   required(:name).value(:string, min_size?: 1, max_size?: 100)
   required(:age).value(:integer, gt?: 0, lteq?: 120)
   ```

5. **Define nested params** for complex input:

   ```ruby
   params do
     required(:user).hash do
       required(:name).value(:string)
       required(:address).hash do
         required(:street).value(:string)
         required(:city).value(:string)
       end
     end
   end
   ```

6. **Define array params**:

   ```ruby
   params do
     required(:tags).array(:string)
     required(:scores).array(:integer)
   end
   ```

7. **Custom rules** for cross-field validation:

   ```ruby
   params do
     required(:password).value(:string, min_size?: 8)
     required(:password_confirmation).value(:string)

     rule(:password_confirmation) do
       key.failure("must match password") unless value == values[:password]
     end
   end
   ```

8. **Invalid params halt automatically**. If validation fails, Hanami halts with 422 and populates `request.params.errors`:

   ```ruby
   def handle(request, response)
     if request.params.errors.any?
       response.status = 422
       response.body = { errors: request.params.errors.to_h }.to_json
       return
     end

     # ... proceed with valid params
   end
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll validate in the Repository instead of the Action" | Params are validated at the HTTP boundary (Action). Repositories receive already-validated data. |
| "I'll skip type coercion and validate as strings only" | Always declare types (`:integer`, `:bool`, `:date`). Coercion catches type errors early. |
| "I'll use `request.params` without defining a `params` block" | Without a `params` block, `request.params` is an untrusted hash. Always define the schema. |
| "I'll put complex business rules in the `params` block" | Params validation checks shape and constraints. Business rules belong in interactors or service objects. |
| "I'll rescue validation errors instead of using halt" | Hanami automatically halts on invalid params. Do not fight the framework. Inspect `request.params.errors` if needed. |
| "I'll define the same params schema in every Action" | Extract shared params to a module or base class if multiple Actions share the same input shape. |

---

## Red Flags

- Actions without `params` blocks
- Manual string validation instead of type coercion
- Business rules inside `params` blocks
- Rescue of validation halts instead of using `request.params.errors`
- Untrusted `request.params` access without schema definition
- Complex nested params without hash/array declarations

---

## Integration

| Related Skill | When to chain |
|---|---|
| **action-anatomy** | Params are defined inside Actions. Master Action structure first. |
| **action-halt-errors** | Invalid params trigger automatic halts. Handle errors gracefully. |
| **action-json-api** | JSON request bodies are parsed and validated through the Params DSL. |
| **dry-monads/result-pattern** | Validated params are passed to interactors that return Success/Failure. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Params DSL) |
|---|---|
| `params.require(:user).permit(:name, :email)` | `params do required(:user).hash { required(:name).value(:string); required(:email).value(:string) } end` |
| `before_action :validate_params` | Automatic halt on invalid params — no manual callback needed |
| `render json: { errors: ... }, status: 422` | Automatic 422 halt; `request.params.errors` contains details |
| Strong Parameters (whitelist) | Schema definition (whitelist + type coercion + constraints) |
| `params[:age].to_i` | `required(:age).value(:integer)` (automatic coercion) |
| Custom validator class | Custom `rule` blocks inside `params` or extract to a module |
