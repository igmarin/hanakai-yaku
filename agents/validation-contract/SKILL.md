---
name: validation-contract
license: MIT
description: >
  Use when implementing validation with dry-validation in Hanami 2.x. Chains inject-dependencies,
  validate-params, handle-result-pattern, and write-action-spec.
metadata:
  ecosystem_sources:
  - dry-rb/dry-validation
  - hanami/hanami-controller
  tags:
  - agents
  - validation
  - dry-validation
  - contracts
  version: 1.0.0
---

# validation-contract

Use this workflow when implementing complex validation with dry-validation in Hanami 2.x.

**Core principle:** Complex validation belongs in dedicated Contract classes, not inline in Actions.

---

## Quick Reference

| Step | Skill | Handoff Condition |
|---|---|---|
| 1. Define Contract | — | Contract class with rules exists |
| 2. Register in DI | `inject-dependencies` | Contract injectable via `Deps` |
| 3. Inject into Action | `validate-params` | Action uses Contract for validation |
| 4. Handle results | `handle-result-pattern` | Action handles Success/Failure |
| 5. Write tests | `write-action-spec` | Contract tested in isolation |

---

## Core Process

1. **[Define Contract]** — Create a dry-validation Contract
   - Define schema with types and constraints
   - Add custom rules for cross-field validation
   - Handoff condition: Contract validates input correctly

   ```ruby
   # app/contracts/user_contract.rb
   module MyApp
     module Contracts
       class UserContract < Dry::Validation::Contract
         params do
           required(:email).value(:string, format?: /\A.+@.+\z/)
           required(:password).value(:string, min_size?: 8)
           required(:password_confirmation).value(:string)
         end

         rule(:password_confirmation) do
           key.failure("must match password") unless value == values[:password]
         end
       end
     end
   end
   ```

2. **[Register in DI]** — Load skill: `inject-dependencies`
   - Register Contract in container
   - Handoff condition: Contract accessible via `Deps["contracts.user_contract"]`

3. **[Inject into Action]** — Load skill: `validate-params`
   - Inject Contract into Action
   - Call Contract instead of inline `params` block for complex validation
   - Handoff condition: Action uses Contract for validation

   ```ruby
   class Create < MyApp::Action
     include Deps["contracts.user_contract"]

     def handle(request, response)
       result = contract.call(request.params[:user])
       if result.failure?
         halt 422, { errors: result.errors.to_h }.to_json
       end

       # ... proceed with valid data
     end
   end
   ```

4. **[Handle Results]** — Load skill: `handle-result-pattern`
   - Return `Success`/`Failure` from service objects
   - Handle `Failure` in Action with appropriate HTTP status
   - Handoff condition: Validation errors map to correct HTTP responses

5. **[Write Tests]** — Load skill: `write-action-spec`
   - Test Contract in isolation with valid and invalid input
   - Test Action with stubbed Contract results
   - Handoff condition: All tests pass

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll put complex validation inline in the Action" | Extract complex validation to a Contract class. Actions should be thin. |
| "I'll skip testing the Contract in isolation" | Contracts have complex logic. Test them directly with various inputs. |
| "I'll forget to register the Contract in the container" | Contracts must be registered to be injected via `Deps`. |
| "I'll return raw error messages without structure" | Return structured errors: `{ errors: { field: ["message"] } }`. |

---

## Red Flags

- Complex validation inline in Actions
- Contracts not tested in isolation
- Contracts not registered in DI container
- Unstructured error responses
- Missing edge case validation tests

---

## Integration

| Related Skill | When to chain |
|---|---|
| **inject-dependencies** | Step 2: Register and inject Contract. |
| **validate-params** | Step 3: Use Contract in Action. |
| **handle-result-pattern** | Step 4: Handle Success/Failure. |
| **write-action-spec** | Step 5: Test Contract and Action. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Validation Contract) |
|---|---|
| `User.new(attrs).valid?` | `contract.call(attrs)` → `result.success?` |
| `user.errors` | `result.errors.to_h` |
| Custom validator class | `Dry::Validation::Contract` subclass |
| `validates :email, format: { with: /.../ }` | `rule` block in Contract |
| Cross-field validation | `rule` block with access to `values` |
| Form object | Contract + Action + service object |
