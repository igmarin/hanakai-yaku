# hanakai-yaku — Agent Guidance

This file tells AI agents how to use this repository.

## What This Repository Is

A curated library of atomic skills for Hanami, dry-rb, and ROM Ruby development, plus callable agents that chain skills into guided workflows. Skills are executable instructions — not documentation. They guide agents through structured workflows with hard gates.

## How Skills Are Organized

Each skill lives in its own directory with a `SKILL.md` entry point:

```
skill-name/
├── SKILL.md          # Entry point — always read this first
├── EXAMPLES.md       # Concrete input/output examples (when present)
├── TEMPLATE.md       # Output structure (when present)
└── HEURISTICS.md     # Reference tables (when present)
```

Read `SKILL.md` first. Load supporting files only when the skill links to them and the content is needed.

## Skill Selection

All skills are organized by category:

| Category | Path | Skills |
|----------|------|--------|
| **Context** | `skills/context/` | `load-context` |
| **Providers** | `skills/providers/` | `configure-providers`, `implement-di` |
| **Actions** | `skills/actions/` | `create-action`, `test-action` *(planned)* |
| **Persistence** | `skills/persistence/` | `create-repository`, `create-relation`, `create-changeset` *(planned)* |
| **dry-rb** | `skills/dry-rb/` | `create-operation`, `create-validation-contract` *(planned)* |
| **Testing** | `skills/testing/` | `write-tests`, `plan-tests` *(planned)* |
| **Slices** | `skills/slices/` | `create-slice`, `test-slice` *(planned)* |
| **Views** | `skills/views/` | `create-view` *(planned)* |

## Non-Negotiable Rule

**Tests gate implementation.** This applies to every skill that produces code:

```
Write test → Run test → Verify it FAILS for the right reason → Implement → Verify it PASSES
```

Every code-producing skill contains a `HARD-GATE` section enforcing this.

## Agents

| Agent | Path | Purpose |
|-------|------|---------|
| **hanami-setup** | `agents/hanami-setup/` | Project onboarding: context → providers → DI → verify |
| **hanami-tdd** *(planned)* | `agents/hanami-tdd/` | TDD feature cycle: plan → test → implement → review |
| **slice-lifecycle** *(planned)* | `agents/slice-lifecycle/` | Slice development: create → test → review |

## Workflow Chaining

Each skill's **Integration** table names the next skill to load. Follow it. Skills are building blocks; agents are the primary unit of value.

## Output Language

All generated artifacts must be in **English** unless the user explicitly requests another language.

## Context First

Before any Hanami implementation or review, load context with `load-context` to discover the app's slices, providers, settings, routes, and established patterns.
