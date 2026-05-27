# Register Provider Task

## Problem

A Hanami team needs help with a task in this area:

Use when registering external dependencies in Hanami 2.x — create provider files at `config/providers/<name>.rb` using `hanami generate provider <name>`, implement lifecycle hooks with `prepare` for requiring gems and `start` for instantiation/registration, register with a descriptive key using `register("name.client", instance)`, always load configuration through `target[:settings]` never raw `ENV`, rescue and log errors in `start` to prevent boot crashes, and verify registration via `Hanami.app["key"]` in console or a lightweight smoke test.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
