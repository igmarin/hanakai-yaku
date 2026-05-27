# Create Slice Task

## Problem

A Hanami team needs help with a task in this area:

Use when creating Hanami Slices — generate a slice with `hanami generate slice <name>`, register it in `config/app.rb` via `slice :name, at: "/path"`, define slice routes in `slices/<name>/config/routes.rb`, configure inter-slice dependencies with `import`/`export` (avoid circular deps: if A imports from B, B must not import from A), and keep slices self-contained for distinct bounded contexts like API, admin, or billing, the main web application.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
