---
name: validation-contract
license: MIT
type: persona
description: >
  Use when implementing validation with dry-validation contracts, schemas, or form/input/params
  validation in Hanami 2.x. Injects dependencies, validates request params using dry-validation
  contracts, handles monadic Success/Failure result patterns, and writes action specs.
  Chains inject-dependencies, validate-params, handle-result-pattern, and write-action-spec.
metadata:
  ecosystem_sources:
  - dry-rb/dry-validation
  - hanami/hanami-controller
  tags:
  - personas
  - validation
  - dry-validation
  - contracts
  version: 1.0.0
---

# validation-contract

Use this workflow when implementing complex validation with dry-validation in Hanami 2.x.

**Core principle:** Complex validation belongs in dedicated Contract classes, not inline in Actions.

---

## Core Process

1. **[Define Contract]** — Create a dry-validation Contract
   - Define schema with types and constraints
   - Add custom rules for cross-field validation

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
   - Register Contract in container so it can be injected via `Deps`

   ```ruby
   # config/providers/contracts.rb
   Hanami.app.register_provider(:contracts) do
     start do
       register("contracts.user_contract", MyApp::Contracts::UserContract.new)
     end
   end
   ```

3. **[Inject into Action]** — Load skill: `validate-params`
   - Inject Contract into Action
   - Call Contract instead of inline `params` block for complex validation

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

   > **Checkpoint:** Before proceeding, run the action spec to verify the contract is correctly injected. If the spec cannot resolve `contracts.user_contract`, confirm the provider is registered and the container has been booted.

4. **[Handle Results]** — Load skill: `handle-result-pattern`
   - Return `Success`/`Failure` from service objects
   - Handle `Failure` in Action with appropriate HTTP status

   ```ruby
   # app/operations/create_user.rb
   class CreateUser
     include Dry::Monads[:result]

     def call(attrs)
       user = User.new(attrs)
       if user.save
         Success(user)
       else
         Failure(:save_failed)
       end
     end
   end

   # app/actions/users/create.rb
   class Create < MyApp::Action
     include Deps["contracts.user_contract", "operations.create_user"]

     def handle(request, response)
       result = user_contract.call(request.params[:user])
       halt 422, { errors: result.errors.to_h }.to_json if result.failure?

       case create_user.call(result.to_h)
       in Success(user)
         response.status = 201
         response.body = { id: user.id }.to_json
       in Failure(:save_failed)
         halt 500, { error: "Could not save user" }.to_json
       end
     end
   end
   ```

5. **[Write Tests]** — Load skill: `write-action-spec`
   - Test Contract in isolation with valid and invalid input
   - Test Action with stubbed Contract results

   ```ruby
   # spec/contracts/user_contract_spec.rb
   RSpec.describe MyApp::Contracts::UserContract do
     subject(:contract) { described_class.new }

     it "passes with valid input" do
       result = contract.call(email: "a@b.com", password: "secret123", password_confirmation: "secret123")
       expect(result).to be_success
     end

     it "fails when passwords do not match" do
       result = contract.call(email: "a@b.com", password: "secret123", password_confirmation: "wrong")
       expect(result.errors[:password_confirmation]).to include("must match password")
     end
   end
   ```

---

## Common Mistakes & Red Flags

| Mistake / Red Flag | Correct Approach |
|---|---|
| Complex validation inline in Actions | Extract to a Contract class. Actions should be thin. |
| Contract not registered in DI container | Register via provider; inject with `Deps["contracts.user_contract"]`. |
| Contracts not tested in isolation | Test directly with valid and invalid inputs before wiring into the Action. |
| Unstructured error responses | Return structured errors: `{ errors: { field: ["message"] } }`. |
| Missing edge case validation tests | Cover cross-field rules and boundary values in Contract specs. |
