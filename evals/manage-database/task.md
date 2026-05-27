# Manage Database Task

## Problem

A Hanami team needs help with a task in this area:

Use when running Hanami 2.x database CLI commands — always confirm HANAMI_ENV and DATABASE_URL before destructive operations, create databases with `hanami db create`, run/revert migrations with `hanami db migrate`/`rollback` validating via `hanami db version`, seed data with `hanami db seed` from `db/seeds.rb`, prepare the full database with `hanami db prepare`, and never edit already-run migrations or use `hanami db drop` without environment confirmation.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
