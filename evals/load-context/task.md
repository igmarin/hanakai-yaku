# Load Context Task

## Problem

A Hanami team needs help with a task in this area:

Loads the Hanami application context before any code, spec, or review work — discovers slices, providers, settings, routes, ROM setup, test framework, DI conventions, and existing patterns, with a mandatory security gate to redact all passwords/credentials/tokens/API keys before note-taking, and a rule to never propose code without first running load-context.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
