# Implement Di Task

## Problem

A Hanami team needs help with a task in this area:

Inject dependencies through Hanami's `auto_inject` using `Deps["provider_key"]` — never call `Hanami.app["key"]` outside of providers, dependencies must be pre-registered by a provider using a descriptive dot-namespaced snake_case key, inject via constructor (no custom `initialize`), pass `instance_double` test stubs through `.new(keyword:)` in specs, validate resolution to catch `Dry::Container::Error` on unregistered keys, and access dependencies by their last key segment — for example `Deps["repos.user_repo"]` → call `user_repo`.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
