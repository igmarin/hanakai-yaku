# Extract Slice Task

## Problem

A Hanami team needs help with a task in this area:

Extract code from the Hanami app module into a dedicated slice without changing behavior — DO NOT change behavior during extraction, every existing test must pass after the move, identify the bounded context, create the target slice with `create-slice`, move files via `git mv` from old namespace to slices/[slice]/ preserving history, update namespaces from App::X to X (for example App::Payments → Payments), update all imports including `Deps[...]` keys and route definitions, and run the full test suite before and after to verify every existing test still passes.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
