# Write Request Spec Task

## Problem

A Hanami team needs help with a task in this area:

Use when writing RSpec request specs for Hanami 2.x Actions — place specs under `spec/requests/`, send JSON request bodies with `.to_json` and `CONTENT_TYPE: application/json` header, assert responses via `last_response.successful?` and `json_body`, test both 404 and 422 error states, and wrap DB-touching specs in a transaction rollback context.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
