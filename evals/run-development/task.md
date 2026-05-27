# Run Development Task

## Problem

A Hanami team needs help with a task in this area:

Use when running Hanami 2.x development commands — `hanami dev` with code reloading though config files require server restart, verify server responds via `curl http://localhost:2300` and recover from port conflicts and config syntax errors, `hanami console` requiring DATABASE_URL set with HANAMI_ENV awareness before destructive operations, using the container to explore slices/relations/repos, and `hanami routes`/`hanami middleware` for stack inspection.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
