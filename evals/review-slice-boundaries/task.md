# Review Slice Boundaries Task

## Problem

A Hanami team needs help with a task in this area:

Reviews Hanami slice boundaries for violations — cross-slice coupling, shared internals, import leaks, provider leaks where a provider registers something that should be slice-scoped, and boundary design — producing findings with severity and concrete recommendations, every finding citing the specific file and line as evidence.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
