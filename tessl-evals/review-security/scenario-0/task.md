# Review Security Task

## Problem

A Hanami team needs help with a task in this area:

Use when conducting a security audit on Hanami 2.x applications — validate params via the Params DSL in every Action, verify CSRF protection is enabled in config/app.rb, audit authentication checks via explicit `before :authenticate!`, check authorization with role/permission checks, never log passwords/tokens/secrets, use ROM query interface to prevent SQL injection (no string interpolation in `where("...")`), never use `raw` on user input in templates, store secrets in settings not hardcoded, and return generic error messages for auth failures.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
