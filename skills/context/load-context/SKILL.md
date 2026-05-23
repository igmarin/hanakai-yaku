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

## Core Process

> **Pattern reference:** See [PATTERNS.md](./PATTERNS.md) for guidance on sampling established patterns from actions, operations, and repositories.

1. **Slice inventory** — list every slice in `slices/`. Note each slice's actions, repositories, relations, operations, and views.
   ```bash
   find slices/ -mindepth 1 -maxdepth 1 -type d
   find slices/ -name '*.rb' | head -40
   ```
   > **Checkpoint:** If `slices/` is empty or missing, this may not be a Hanami 2.x app. Verify with `cat config/app.rb` or check `Gemfile` for the `hanami` gem version before continuing.

2. **Provider inventory** — read `config/providers/`. Identify every registered provider and its dependencies (ROM connections, external services, application components).
   ```bash
   cat config/providers/*.rb
   ```
   > **Security checkpoint:** Redact all secrets (passwords, API keys, tokens, secret keys) when summarizing provider configuration. Replace with `[REDACTED]` or `*****`.
   > **Checkpoint:** If no provider files are found, note this explicitly in your output — DI and ROM steps may need to rely on inline configuration instead.

3. **Settings** — read `config/settings.rb` (or `config/settings/`). Note environment-specific values, type constraints, and configured services.
   ```bash
   cat config/settings.rb 2>/dev/null || cat config/settings/*.rb
   ```
   > **Security checkpoint:** Redact all secrets (passwords, API keys, tokens, secret keys) when summarizing settings. Replace with `[REDACTED]` or `*****`.

4. **Routes** — read `config/routes.rb`. Map the URL space to slices and actions.
   ```bash
   cat config/routes.rb
   ```

5. **ROM setup** — read `config/providers/rom.rb` (or equivalent). Identify database adapters, relation paths, and migration setup.
   ```bash
   cat config/providers/rom.rb 2>/dev/null || grep -r 'rom' config/providers/ -l
   ```

6. **Test setup** — detect test framework (RSpec), spec helper conventions, and slice test isolation patterns.
   ```bash
   cat spec/spec_helper.rb 2>/dev/null
   find spec/ -name '*_helper.rb' | head -10
   ```

7. **Dependency injection** — detect auto_inject usage patterns. Note whether `include Deps[...]` is used in actions, operations, and repositories.
   ```bash
   grep -r 'include Deps' slices/ --include='*.rb' | head -10
   grep -r 'auto_inject' slices/ config/ --include='*.rb' | head -10
   ```

8. **Existing patterns** — sample 2-3 actions, operations, and repositories to understand the established style (naming, response contracts, error handling).
   ```bash
   find slices/ -path '*/actions/*.rb' | head -3 | xargs cat
   find slices/ -path '*/operations/*.rb' | head -3 | xargs cat
   find slices/ -path '*/repositories/*.rb' | head -3 | xargs cat
   ```

## Completion Gate

Before proceeding to any implementation work, confirm that all seven output sections below have been populated. If any section could not be filled (e.g., no providers found), record that explicitly as `— (not found)` rather than skipping the row. Do not proceed to implementation until this checklist is complete:

- [ ] Slice map populated (or confirmed absent)
- [ ] Provider map populated (or confirmed absent)
- [ ] Settings summary recorded
- [ ] Route summary recorded
- [ ] Test infrastructure identified
- [ ] DI conventions noted
- [ ] Pattern notes captured from sampled files

## Output Style

1. **Slice map** — `| Slice | Actions | Repositories | Operations | Views |`
2. **Provider map** — `| Provider | Source | Registered components |`
3. **Settings summary** — key settings values with types. **Redact all secrets** (passwords, API keys, tokens, secret keys) and replace with `[REDACTED]`.
4. **Route summary** — top-level routes grouped by slice.
5. **Test infrastructure** — framework, spec helper location, slice test isolation.
6. **DI conventions** — auto_inject usage, Deps include style.
7. **Pattern notes** — established conventions for actions, operations, repositories.
8. **English only** unless user requests otherwise.

### Example Output (Slice Map)

| Slice | Actions | Repositories | Operations | Views |
|-------|---------|--------------|------------|-------|
| `admin` | `users/index`, `users/show`, `users/create` | `users_repo` | `create_user` | `users/index`, `users/show` |
| `api` | `v1/health`, `v1/users/index` | — | — | — |

> Fill in each column from the discovered files; leave `—` where no files exist.

## Integration

| Skill | When to chain |
|-------|---------------|
| **configure-providers** | After context, to set up or verify provider configuration |
| **implement-di** | After context, to implement or verify DI patterns |
| **hanami-setup** | First step in the project onboarding agent |
