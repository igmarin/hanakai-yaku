# Build Json Api Task

## Problem

A Hanami team needs help with a task in this area:

Use when building JSON API endpoints in Hanami 2.x Actions — set `response.format = :json`, use dedicated serializers to encode response bodies, write round-trip serialize→parse tests asserting fields match with `.iso8601` timestamps, include pagination metadata with `{data:, meta:}` shape, return consistent error shapes across endpoints, and rescue `JSON::ParserError` with 400 status.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
