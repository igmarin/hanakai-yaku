# Handle Errors Task

## Problem

A Hanami team needs help with a task in this area:

Use when handling errors and halting requests in Hanami 2.x Actions — fail fast with `halt STATUS, {error:}.to_json` for early returns, rescue `StandardError` (never `Exception`) logging full details internally but returning generic messages to clients, let invalid params halt automatically with 422 before `#handle` runs without manual `params.valid?` checks, and match error response format to action format (no HTML errors in JSON actions).

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
