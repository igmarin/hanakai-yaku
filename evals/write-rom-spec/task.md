# Write Rom Spec Task

## Problem

A Hanami team needs help with a task in this area:

Use when writing ROM specs in Hanami 2.x — configure transactional rollback via a shared `"db rollback"` RSpec context wrapping every spec with `transaction(rollback: :always, auto_savepoint: true)`, place relation specs under `spec/relations/` and repository specs under `spec/repos/`, test custom Relation query methods with fully defined test data via `relation.insert(...)`, verify Repository CRUD operations including `one!` raising `ROM::TupleCountMismatchError` for missing tuples, and run specs to confirm failure before implementing.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
