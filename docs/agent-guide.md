# Agent Guide — hanakai-yaku

Agent workflows for Hanami, dry-rb, and ROM development.

---

## Hanami Setup Agent

Orchestrates project onboarding: context discovery → provider configuration → DI → verification.

### Phase Flow

```mermaid
graph TD
    A[New Project / Onboarding] --> B["Phase 1<br/>Context Loading<br/>load-context"]
    B --> C{"Context Loaded?"}
    C -->|No| B
    C -->|Yes| D["Phase 2<br/>Provider Configuration<br/>configure-providers"]
    D --> E["Phase 3<br/>DI Implementation<br/>implement-di"]
    E --> F["Phase 4<br/>Verification"]
    F --> G{"Providers Verified?"}
    G -->|No| F
    G -->|Yes| H[Setup Complete]
```

| Phase | Skill | Gate |
|-------|-------|------|
| 1. Context Loading | `load-context` | **Context Loaded** |
| 2. Provider Configuration | `configure-providers` | Quality Check |
| 3. DI Implementation | `implement-di` | Quality Check |
| 4. Verification | — | **Providers Verified** |

**Dependencies:** `load-context`, `configure-providers`, `implement-di`

---

## Planned Agents

### hanami-tdd *(Group 2)*

TDD feature cycle: Plan tests → Write tests → Implement → Review.

### slice-lifecycle *(Group 3)*

Slice development: Create slice → Test slice → Review slice boundaries.

---

## See Also

- [Skill Catalog](reference/skill-catalog.md) — All skills and agents
- [Integration Matrix](reference/integration-matrix.md) — Complete chaining reference
