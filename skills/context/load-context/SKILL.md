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

> [!IMPORTANT]
> **Security Gate:** Always redact all passwords, credentials, tokens, and API keys. Replace them with `[REDACTED]` or `*****` in any notes or summaries.

> **Pattern reference:** For details on sampling, see [PATTERNS.md](PATTERNS.md).

1. **Slice inventory** — list every slice in `slices/`:
   ```bash
   find slices/ -mindepth 1 -maxdepth 1 -type d
   find slices/ -name '*.rb' | head -40
   ```
   *Checkpoint:* If `slices/` is missing, verify this is a Hanami 2.x application by checking `Gemfile` or `config/app.rb`.

2. **Provider inventory** — read `config/providers/` to identify registered integrations:
   ```bash
   cat config/providers/*.rb
   ```

3. **Settings** — inspect `config/settings.rb` for environment variables and type constraints:
   ```bash
   cat config/settings.rb 2>/dev/null || cat config/settings/*.rb
   ```

4. **Routes** — read `config/routes.rb` to map URL endpoints:
   ```bash
   cat config/routes.rb
   ```

5. **ROM setup** — identify database adapters, relation paths, and migration setup:
   ```bash
   cat config/providers/rom.rb 2>/dev/null || grep -r 'rom' config/providers/ -l
   ```

6. **Test setup** — detect testing frameworks and transactional helpers:
   ```bash
   cat spec/spec_helper.rb 2>/dev/null
   find spec/ -name '*_helper.rb' | head -10
   ```

7. **Dependency injection** — analyze auto_inject usages and mixin styles:
   ```bash
   grep -r 'include Deps' slices/ --include='*.rb' | head -10
   grep -r 'auto_inject' slices/ config/ --include='*.rb' | head -10
   ```

8. **Existing patterns** — sample actions, operations, and repos:
   ```bash
   find slices/ -path '*/actions/*.rb' | head -3 | xargs cat
   find slices/ -path '*/operations/*.rb' | head -3 | xargs cat
   find slices/ -path '*/repositories/*.rb' | head -3 | xargs cat
   ```

---

## Completion Gate

Before proceeding to any implementation, populate the 7 sections of the context map. For details on the output format and examples, refer to [CONTEXT-OUTPUT-FORMAT.md](CONTEXT-OUTPUT-FORMAT.md).

- [ ] Slice map populated
- [ ] Provider map populated
- [ ] Settings summary recorded
- [ ] Route summary recorded
- [ ] Test infrastructure identified
- [ ] DI conventions noted
- [ ] Pattern notes captured

---

## Integration

| Skill | When to chain |
|-------|---------------|
| **configure-providers** | After context, to set up or verify provider configuration |
| **implement-di** | After context, to implement or verify DI patterns |
| **hanami-setup** | First step in the project onboarding agent |
