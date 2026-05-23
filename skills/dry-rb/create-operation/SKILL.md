---
name: create-operation
license: MIT
description: >
  Creates a dry-operation or dry-transaction that encapsulates a business workflow.
  Composes validation, persistence, and side effects into explicit steps returning
  Success or Failure. Hanami convention: actions delegate to operations.
  Trigger words: operation, dry-operation, dry-transaction, business logic,
  workflow, service, Dry::Operation, step, compose operations.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Creating a dry-operation

Encapsulate a business workflow in an operation. Each step is explicit — success flows forward, failure short-circuits.

## Quick Reference

- **Framework:** `dry-operation` for sequential steps, `dry-transaction` for composed operations with rollback.
- **Return:** Always `Success(value)` or `Failure(error)`.
- **DI:** Use `include Deps[...]` for dependencies.
- **Test:** Pass test doubles through the constructor. Verify step ordering.

## HARD-GATE

```text
Write test → Run test → Verify it FAILS → Implement → Verify it PASSES
DO NOT put business logic in actions. Actions delegate to operations.
DO NOT return raw values — always wrap in Success or Failure.
```

## Core Process

1. **Plan the workflow** — list every step in order. Each step is a method or a callable.
2. **Create the operation class** in `slices/<slice>/operations/<namespace>/`:
   ```ruby
   module Users
     class CreateUser < Dry::Operation
       include Deps["repositories.user_repo"]

       def call(input)
         attrs = step validate(input)
         user  = step persist(attrs)
         step notify(user)
         user
       end

       private

       def validate(input) = # returns Success(attrs) or Failure(errors)
       def persist(attrs) = # returns Success(user) or Failure(error)
       def notify(user)   = # returns Success(true) or Failure(error)
     end
   end
   ```
3. **Each step** — if it returns `Failure`, the operation stops and returns that failure.
4. **Compose operations** by injecting them as dependencies. Never call one operation from inside another's private methods.
5. **Use operations from actions** — the action calls the operation and maps the result to an HTTP response.

## Extended Resources (Progressive Disclosure)

Load these files only when needed:

- **[OPERATION_PATTERNS.md](./OPERATION_PATTERNS.md)** — Patterns: steps, transactions, composition, error handling, testing.

## Output Style

1. **Operation class** — complete implementation with `include Deps[...]`.
2. **Step methods** — each private method with explicit return types.
3. **Spec** — RSpec with test doubles, verifying Success and Failure paths.
4. **Action integration** — how the action calls this operation.
5. **English only** unless user requests otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **create-validation-contract** | Before the operation, to define validation rules |
| **create-action** | After the operation, to wire it to an HTTP endpoint |
| **implement-di** | To inject repositories and services into the operation |
| **tdd-loop** agent | Full TDD cycle including operation testing |
