# Write Action Spec Task

## Problem

A Hanami team needs help with a task in this area:

Use when writing isolated RSpec unit specs for Hanami 2.x Actions — place spec under `spec/actions/` mirroring the action namespace with `type: :action` metadata, stub all `Deps[...]` dependencies via `instance_double` passed to `described_class.new(dep: stub)`, test both success (200/201) and error (422/500) paths, assert on `response.status`, `response.headers`, and action exposures without hitting the database or HTTP stack, and confirm the spec fails before implementing the Action.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
