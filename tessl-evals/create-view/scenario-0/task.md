# Create View Task

## Problem

A Hanami team needs help with a task in this area:

Use when creating Hanami 2.x Views — define a View class inheriting from `Hanami::View` in `app/views/`, declare exposures via `expose :name` that receive pre-fetched data from Actions (never query the database in Views or templates), place templates alongside Views matching the namespace path, use Parts for decorator-style logic via `expose :model, as: :model_part`, and avoid instance variables in templates (templates receive locals from `expose`).

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
