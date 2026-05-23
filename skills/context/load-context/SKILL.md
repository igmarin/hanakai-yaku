---
name: load-context
license: MIT
description: >
  Loads the Hanami application context before any code, spec, or review work.
  Discovers slices, providers, settings, routes, relations, and established
  patterns. The non-negotiable first step for every Hanami task.
  Trigger words: load context, before I code, what does this app use, match
  existing style, load-context, show me the app, discover structure, context.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Loading Hanami Application Context

Load the minimum context needed to work safely in a Hanami codebase. Discover structure before proposing changes.

## Quick Reference

- **Discover:** Slices, providers, settings, routes, relations, existing patterns.
- **Verify:** Test framework, DI conventions, ROM setup.
- **Rule:** Never propose code without first running `load-context`.

## HARD-GATE

```text
DO NOT propose code, specs, operations, or any implementation artifact
before completing load-context. You must know the app's structure.
```

## Core Process

1. **Slice inventory** — list every slice in `slices/`. Note each slice's actions, repositories, relations, operations, and views.
2. **Provider inventory** — read `config/providers/`. Identify every registered provider and its dependencies (ROM connections, external services, application components).
3. **Settings** — read `config/settings.rb` (or `config/settings/`). Note environment-specific values, type constraints, and configured services.
4. **Routes** — read `config/routes.rb`. Map the URL space to slices and actions.
5. **ROM setup** — read `config/providers/rom.rb` (or equivalent). Identify database adapters, relation paths, and migration setup.
6. **Test setup** — detect test framework (RSpec), spec helper conventions, and slice test isolation patterns.
7. **Dependency injection** — detect auto_inject usage patterns. Note whether `include Deps[...]` is used in actions, operations, and repositories.
8. **Existing patterns** — sample 2-3 actions, operations, and repositories to understand the established style (naming, response contracts, error handling).

## Extended Resources (Progressive Disclosure)

Load these files only when needed:

- **[PATTERNS.md](./PATTERNS.md)** — How to sample established patterns from the app (action signatures, operation contracts, repository query style).

## Output Style

1. **Slice map** — `| Slice | Actions | Repositories | Operations | Views |`
2. **Provider map** — `| Provider | Source | Registered components |`
3. **Settings summary** — key settings values with types.
4. **Route summary** — top-level routes grouped by slice.
5. **Test infrastructure** — framework, spec helper location, slice test isolation.
6. **DI conventions** — auto_inject usage, Deps include style.
7. **Pattern notes** — established conventions for actions, operations, repositories.
8. **English only** unless user requests otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **configure-providers** | After context, to set up or verify provider configuration |
| **implement-di** | After context, to implement or verify DI patterns |
| **hanami-setup** | First step in the project onboarding agent |
