# Skill Catalog — hanakai-yaku

Catalog of Hanami, dry-rb, and ROM development skills. 35 skills and 10 personas available.

---

## Quick Navigation

**Skills:** [load-context](#load-context) · [configure-providers](#configure-providers) · [implement-di](#implement-di)
**Personas:** [hanami-setup](#hanami-setup-persona)

---

## Skills

### load-context

| Path | `skills/context/load-context/SKILL.md` |
| Category | Context |
| Description | Load Hanami app structure before any code work |
| Trigger Words | "load context", "before I code", "what does this app use", "discover structure" |

**What it does:** Discovers all slices, providers, settings, routes, relations, and established patterns in a Hanami app. The non-negotiable first step before any implementation.

**HARD-GATE:** Do not propose code without completing load-context.

**Next after use:** `configure-providers` (after context, to set up providers) or `hanami-setup` (first step in onboarding).

---

### configure-providers

| Path | `skills/providers/configure-providers/SKILL.md` |
| Category | Providers |
| Description | Configure Hanami providers for services and databases |
| Trigger Words | "provider", "configure", "ROM setup", "external service", "register component" |

**What it does:** Creates provider files for external services, database connections, and application components. Integrates with Hanami settings for environment configuration.

**HARD-GATE:** Never hardcode credentials. Use settings for all environment values.

**Next after use:** `implement-di` (inject the provider into consumers).

---

### implement-di

| Path | `skills/providers/implement-di/SKILL.md` |
| Category | Providers |
| Description | Implement dependency injection with dry-system auto_inject |
| Trigger Words | "dependency injection", "DI", "auto_inject", "Deps", "inject" |

**What it does:** Adds `include Deps[...]` to actions, operations, and repositories. Ensures dependencies are injected through the constructor. Provides testing patterns for DI.

**HARD-GATE:** Never call the container directly. Always inject through the constructor.

**Next after use:** Write tests with injected test doubles; proceed to implementation.

---

## Personas

### hanami-setup Persona

| Path | `skills/personas/hanami-setup/SKILL.md` |
| Description | Project onboarding lifecycle |

**Phases:** Context Loading → Provider Configuration → DI Implementation → Verification

**Hard Gates:** Context Loaded, Providers Verified

**Dependencies:** `load-context`, `configure-providers`, `implement-di`

---

## Planned (Future Groups)

| Skill/Agent | Category | Group |
|-------------|----------|-------|
| `create-action` | Actions | Group 2 |
| `test-action` | Actions | Group 2 |
| `create-repository` | Persistence | Group 2 |
| `create-relation` | Persistence | Group 2 |
| `create-changeset` | Persistence | Group 2 |
| `create-operation` | dry-rb | Group 2 |
| `create-validation-contract` | dry-rb | Group 2 |
| `write-tests` | Testing | Group 2 |
| `plan-tests` | Testing | Group 2 |
| `hanami-tdd` (persona) | Personas | Group 2 |
| `create-slice` | Slices | Group 3 |
| `test-slice` | Slices | Group 3 |
| `extract-slice` | Slices | Group 3 |
| `review-slice-boundaries` | Slices | Group 3 |
| `create-view` | Views | Group 3 |
| `design-routes` | Actions | Group 3 |
| `review-migration` | Persistence | Group 3 |
| `slice-lifecycle` (persona) | Personas | Group 3 |

---

## See Also

- [Integration Matrix](integration-matrix.md) — How skills chain together
- [Persona Guide](../persona-guide.md) — Persona workflows with Mermaid diagrams
- [Architecture](../architecture.md) — Repository layout and conventions
