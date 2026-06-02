---
name: create-validation-contract
license: MIT
type: atomic
description: >
  Define type-safe validation contracts with `Dry::Validation::Contract` — declare expected fields and types in `schema do` blocks with `required(:field).filled(:string)` and `optional(:field)`, write custom predicates in `rule(:field) do` blocks returning `key.failure("message")` on invalid input, call the contract as the first step in an operation wrapping the result in `Success(result.to_h)` or `Failure(result.errors.to_h)`, and write tests asserting `.be_success` for valid input and `.be_failure` with specific `result.errors[:field]` assertions for invalid input, using TDD red-green-refactor. Use when validating request params, operation input, or any structured data.
  Trigger words: validation, contract, dry-validation, params, schema,
  Dry::Validation::Contract, validate input, type-safe, custom predicate.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Creating a Validation Contract

Define type-safe, composable validation rules with dry-validation contracts.

## Quick Reference

- **Location:** `slices/<slice>/contracts/` or inline in the operation.
- **Structure:** `Dry::Validation::Contract` with `schema` and `rule` blocks.
- **Usage:** `contract.call(params)` returns a result with `.success?` and `.errors`.
- **Rule:** Every operation that accepts user input uses a contract.

## HARD-GATE

```text
Write test → Run test → Verify it FAILS → Implement → Verify it PASSES
DO NOT use raw hashes as operation input. Validate through a contract first.
DO NOT put validation logic in actions. Contracts are the single source of validation.
```

## Core Process

> **Pattern reference:** See [CONTRACT_PATTERNS.md](./CONTRACT_PATTERNS.md) for examples of custom predicates, nested schemas, composed contracts, and testing patterns.

1. **Define the contract** — declare expected fields, types, and rules:
   ```ruby
   module Users
     class CreateContract < Dry::Validation::Contract
       schema do
         required(:email).filled(:string)
         required(:name).filled(:string, min_size?: 2)
         optional(:role).filled(:string, included_in?: %w[admin member])
       end

       rule(:email) do
         key.failure("must be a valid email") unless value.match?(URI::MailTo::EMAIL_REGEXP)
       end
     end
   end
   ```
2. **Use in the operation** — call the contract as the first step:
   ```ruby
   def validate(input)
     result = CreateContract.new.call(input)
     result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
   end
   ```
3. **Custom predicates and composed contracts** — for reusable validation rules and shared fields (e.g., pagination params). If a `CONTRACT_PATTERNS.md` companion file is present in the bundle, consult it for executable examples of custom predicates, composed contracts, i18n error messages, and nested schemas.
4. **Test the contract** — verify valid and invalid inputs independently from the operation:
   ```ruby
   RSpec.describe Users::CreateContract do
     subject(:contract) { described_class.new }

     context "with valid input" do
       it "succeeds" do
         result = contract.call(email: "user@example.com", name: "Alice")
         expect(result).to be_success
         expect(result.to_h).to include(email: "user@example.com", name: "Alice")
       end
     end

     context "with invalid input" do
       it "fails with email error" do
         result = contract.call(email: "not-an-email", name: "Alice")
         expect(result).to be_failure
         expect(result.errors[:email]).to include("must be a valid email")
       end

       it "fails when name is too short" do
         result = contract.call(email: "user@example.com", name: "A")
         expect(result).to be_failure
         expect(result.errors[:name]).to be_present
       end
     end
   end
   ```

## Output Style

1. **Contract class** — complete schema and rule definitions.
2. **Operation integration** — how the operation uses the contract.
3. **Spec** — test valid inputs (Success) and invalid inputs (Failure with specific errors).
4. **English only** unless user requests otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **create-operation** | After defining the contract, use it as the first step of the operation |
| **create-action** | Contracts validate action params before they reach the operation |
