# Create Operation Task

## Problem

A Hanami team needs help with a task in this area:

Encapsulate a business workflow in a `Dry::Operation` with explicit steps returning `Success(value)` or `Failure(error)` — inject dependencies via `include Deps[...]`, place the class in `slices/<slice>/operations/`, compose operations by injecting them as dependencies (never call one operation from inside another's private methods), pass test doubles through the constructor to verify step ordering, and delegate from actions that map results to HTTP responses.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
