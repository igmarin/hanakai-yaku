# Test Slice Task

## Problem

A Hanami team needs help with a task in this area:

Test a Hanami slice in isolation — load only the slice under test with `:slice` RSpec metadata tag, mock cross-slice dependencies, never reach into another slice's internals, a slice test must NOT depend on another slice booting, and test the public interface through action specs with stubbed operations, operation specs with test doubles through constructor, repository specs against a test database, and integration specs across the full slice workflow.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
