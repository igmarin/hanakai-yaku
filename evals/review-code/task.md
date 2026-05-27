# Review Code Task

## Problem

A Hanami team needs help with a task in this area:

Use when reviewing Hanami 2.x code for quality and convention adherence — check Action responsibility at ≤~10 lines delegating business logic, verify DI via `include Deps[]` with no `Hanami.app["key"]` direct access, audit query locations ensuring all DB queries live in Repositories/Relations, inspect Repositories returning Entities not raw hashes, review Views receiving pre-fetched data only, check error handling logging+generic messages without exposing e.message, and assess test coverage for 400/404/422/500 paths.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
