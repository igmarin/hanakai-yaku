# Skill Architecture — hanakai-yaku

Conventions and structure for every `SKILL.md` in this library.

## Directory Structure

```text
hanakai-yaku/
├── docs/                    # Documentation
│   ├── architecture.md
│   ├── agent-guide.md
│   ├── calling-skills.md
│   └── reference/
│       ├── skill-catalog.md
│       └── integration-matrix.md
├── agents/                  # Orchestrated agent skills
│   └── hanami-setup/
│       └── SKILL.md
├── skills/                  # Categorized skills
│   └── <category>/          # e.g., context, providers, actions
│       └── <skill-name>/    # One directory per skill
│           ├── SKILL.md     # Main skill file (required)
│           └── reference.md # Optional companion material
├── SKILL.md                 # Root orchestrator
├── CONTEXT.md               # Domain glossary
├── AGENTS.md                # Agent guidance
├── tile.json                # Skill registry
├── agents.json              # Agent registry
└── README.md
```

## SKILL.md Structure

Every skill follows 6 sections in order:

```text
1. Frontmatter (YAML)       — name, description, metadata
2. Quick Reference          — scannable for fast lookup
3. HARD-GATE               — non-negotiable blocking rules
4. Core Process             — step-by-step procedure
5. Output Style             — exact shape of artifacts
6. Integration              — predecessor/successor skills
```

### Frontmatter

```yaml
---
name: skill-name
license: MIT
description: >
  Use when [concrete trigger conditions]. Covers [key topics].
  Trigger words: comma, separated, discovery, terms.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
```

**Rules:**
- `name` equals directory name (kebab-case).
- `description` starts with action-oriented trigger language.
- Max 1024 characters for frontmatter.
- Front-loaded tokens should be under 100.

### HARD-GATE

For code-producing skills, the gate is always:

```text
Write test → Run test → Verify it FAILS → Implement → Verify it PASSES
```

Non-code skills have domain-specific gates.

## Skill Reference Formats

| Context | Format | Example |
|---------|--------|---------|
| `tile.json` and `agents.json` | Full path | `skills/context/load-context/SKILL.md` |
| Agent body (activate calls) | Category-path | `context/load-context` |
| Integration tables | Short name | `load-context` |

## Skill Types

### Context Skills
Load and discover. Do not produce code.

- `load-context`

### Configuration Skills
Set up infrastructure. Produce configuration files.

- `configure-providers`
- `implement-di`

### Code-Producing Skills *(planned)*
Follow TDD gate. Produce implementation code.

- `create-action`, `create-repository`, `create-operation`, etc.

## Approval Gates

### Context Loaded Gate
Defined in: `load-context`, `hanami-setup`. Context must be discovered before any code.

### Providers Verified Gate
Defined in: `configure-providers`, `hanami-setup`. All providers must boot without errors.

### TDD Gate *(planned)*
Defined in: All code-producing skills. Test must exist, run, and fail before implementation.
