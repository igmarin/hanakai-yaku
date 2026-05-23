---
name: create-validation-contract
license: MIT
description: >
  Creates a dry-validation contract for type-safe input validation in Hanami
  actions and operations. Covers schema definition, custom predicates, error
  messages, and contract composition. Use when validating request params,
  operation input, or any structured data.
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
3. **Custom predicates** — for reusable validation rules across contracts.
4. **Compose contracts** — inherit or include shared contract modules for common fields (e.g., pagination params).
5. **Test the contract** — verify valid and invalid inputs independently from the operation.

## Extended Resources (Progressive Disclosure)

Load these files only when needed:

- **[CONTRACT_PATTERNS.md](./CONTRACT_PATTERNS.md)** — Custom predicates, composed contracts, i18n error messages, nested schemas.

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
