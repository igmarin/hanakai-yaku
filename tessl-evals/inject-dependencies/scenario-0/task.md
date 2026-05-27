# Inject Dependencies Task

## Problem

A Hanami team needs help with a task in this area:

Use when injecting dependencies in Hanami 2.x — always use `include Deps["dir.name"]` to inject (never call `Hanami.app["key"]` directly outside of providers), derive container keys from file paths via `app/{dir}/{name}.rb` → `"{dir}.{name}"`, exclude ROM-managed relations/structs/entities from auto-registration via `no_auto_register_paths`, access the dependency by its last key segment — for example `Deps["repos.user_repo"]` → use `user_repo`, and override dependencies in tests by passing stubs to `.new(keyword:)`.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
