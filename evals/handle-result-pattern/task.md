# Handle Result Pattern Task

## Problem

A Hanami team needs help with a task in this area:

Use when using the dry-monads Result pattern in Hanami 2.x — wrap outcomes in `Success(value)` or `Failure(error_object)`, chain operations with `Do notation` using `include Dry::Monads::Do.for(:call)` and `yield` inside the `call` method for sequential flows, inject the service object via `Deps["key"]` after registering it in a provider, handle results in Actions with pattern matching (`case result; in Success(v); ...; in Failure(e); ...; end`) rather than unsafe `value!` unwrapping, and model expected failures as data not exceptions.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
