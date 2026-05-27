# Decorate With Parts Task

## Problem

A Hanami team needs help with a task in this area:

Use when creating View Parts for decorator-style logic in Hanami 2.x — define Part classes inheriting from `Hanami::View::Part`, delegate attributes to the wrapped value via `delegate :name, :email, to: :value`, expose data as a Part in Views with `expose :model, as: :model_part`, add presentation methods returning formatted strings or booleans (no HTML generation and no database queries in Parts), and access the raw underlying object via the `value` method when needed.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
