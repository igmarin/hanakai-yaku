# hanakai-yaku — Docs

Hanami, dry-rb, and ROM development skills for AI agents.

## Quick Navigation

| Need | Document |
|------|----------|
| Browse all skills and agents | [reference/skill-catalog.md](reference/skill-catalog.md) |
| Understand skill chaining | [reference/integration-matrix.md](reference/integration-matrix.md) |
| Agent workflows with diagrams | [agent-guide.md](agent-guide.md) |
| Repository structure and conventions | [architecture.md](architecture.md) |
| Invoke skills and agents | [calling-skills.md](calling-skills.md) |

## Skill Categories

| Category | Skills |
|----------|--------|
| Context | `load-context` |
| Providers | `configure-providers`, `implement-di` |
| Actions *(planned)* | `create-action`, `test-action` |
| Persistence *(planned)* | `create-repository`, `create-relation`, `create-changeset` |
| dry-rb *(planned)* | `create-operation`, `create-validation-contract` |
| Testing *(planned)* | `write-tests`, `plan-tests` |
| Slices *(planned)* | `create-slice`, `test-slice` |
| Views *(planned)* | `create-view` |

## Agents

| Agent | Focus |
|-------|-------|
| `hanami-setup` | Project onboarding: Context → Providers → DI → Verify |
| `hanami-tdd` *(planned)* | TDD feature cycle: Plan → Test → Implement → Review |
| `slice-lifecycle` *(planned)* | Slice development: Create → Test → Review |
