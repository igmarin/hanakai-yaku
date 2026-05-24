# Hanami Context Discovery Output Format

This document details the expected output formats and tables when presenting the results of a Hanami application context discovery.

---

## Required Output Structure

Always present the discovered application details in these exact seven sections. If a component is absent, specify `— (not found)` rather than omitting the entry.

### 1. Slice Map
A Markdown table mapping all detected slices to their constituent files:

| Slice | Actions | Repositories | Operations | Views |
|-------|---------|--------------|------------|-------|
| `admin` | `users/index`, `users/show` | `users_repo` | `create_user` | `users/index`, `users/show` |
| `api` | `v1/health`, `v1/users/index` | — | — | — |

### 2. Provider Map
A Markdown table of third-party or library integrations:

| Provider | Source | Registered components |
|----------|--------|-----------------------|
| `rom` | `config/providers/rom.rb` | `db.rom`, `db.gateway` |
| `mailer` | `config/providers/mailer.rb` | `mailer.client` |

### 3. Settings Summary
List of environment configurations and types defined in `config/settings.rb`.
> [!IMPORTANT]
> **Privacy Gate:** Always redact all values containing secrets (passwords, host tokens, database credentials, API keys) and replace them with `[REDACTED]` or `*****`.

### 4. Route Summary
List of top-level route namespaces and entry points grouped by slice.

### 5. Test Infrastructure
- Testing framework detected (e.g. RSpec).
- Spec helpers and support file locations.
- Any transactional db setup / isolation configurations found.

### 6. Dependency Injection (DI) Conventions
- Inject mixin naming conventions (e.g. `Deps`).
- Inject usage patterns across actions/operations (auto-injection configuration).

### 7. Established Pattern Notes
- Code organization conventions identified from sampled action, repository, and operation files.
