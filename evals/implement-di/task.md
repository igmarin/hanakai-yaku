# Implement Di Task

## Problem

A Hanami team needs help with a task in this area:

Inject dependencies through the constructor using Hanami's `auto_inject` and `Deps["provider_key"]` — never call `Hanami.app["key"]` outside of providers, dependencies must be registered by a provider first, pass `instance_double` test doubles through the constructor in specs, and validate key resolution to avoid `Dry::Container::Error` on unregistered keys.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
