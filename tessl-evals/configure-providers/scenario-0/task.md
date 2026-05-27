# Configure Providers Task

## Problem

A Hanami team needs help with a task in this area:

Configure Hanami providers at `config/providers/[name].rb` using `Hanami.app.register_provider(:name) do [...] end` — define settings in `config/settings.rb` if the service needs configuration, implement lifecycle with `prepare` for requiring gems and `start` for instantiation using `target["settings"]` to access config (never hardcode credentials or use raw ENV), register with a descriptive key via `register("key", instance)`, and verify the provider boots without errors.

The team has asked for a concise implementation artifact that a reviewer can inspect without needing to observe the agent's process.

## Output

Create `answer.md` with:

- a short plan for the work
- the concrete Hanami-oriented artifact or recommendation
- the verification steps or quality gates that should be run
- any assumptions that affect the result
