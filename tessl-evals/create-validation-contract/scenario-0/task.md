# Create Validation Contract Task

## Problem

A Hanami team needs help with a task in this area:

Define type-safe validation contracts with `Dry::Validation::Contract` — declare expected fields and types in `schema do` blocks with `required(:field).filled(:string)` and `optional(:field)`, write custom predicates in `rule(:field) do` blocks returning `key.failure("message")` on invalid input, call the contract as the first step in an operation wrapping the result in `Success(result.to_h)` or `Failure(result.errors.to_h)`, and write tests asserting `.be_success` for valid input and `.be_failure` with specific `result.errors[:field]` assertions for invalid input, using TDD red-green-refactor.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
