# Skill Architecture — hanakai-yaku

Conventions and structure for every `SKILL.md` in this library.

## Directory Structure

```text
hanakai-yaku/
├── docs/                    # Documentation
│   ├── architecture.md
│   ├── persona-guide.md
│   ├── calling-skills.md
│   └── reference/
│       ├── skill-catalog.md
│       └── integration-matrix.md
├── skills/personas/        # Orchestrating personas
│   └── hanami-setup/
│       └── SKILL.md
├── skills/                  # Categorized skills
│   └── <category>/          # e.g., context, providers, actions
│       └── <skill-name>/    # One directory per skill
│           ├── SKILL.md     # Main skill file (required)
│           └── reference.md # Optional companion material
├── SKILL.md                 # Root orchestrator (type: catalog)
├── directory.json           # Skill + persona registry
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
type: atomic            # atomic | persona | catalog
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
- `type` is required: `atomic` for standalone skills, `persona` for orchestrating workflows, `catalog` for the root SKILL.md.
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
| `directory.json` | Full path | `skills/context/load-context/SKILL.md` |
| Persona body (activate calls) | Category-path | `context/load-context` |
| Integration tables | Short name | `load-context` |

## Skill Types

### Context Skills
Load and discover. Do not produce code.

- `load-context`

### Configuration Skills
Set up infrastructure. Produce configuration files.

- `configure-providers`
- `implement-di`

### Code-Producing Skills
Follow TDD gate. Produce implementation code.

All atomic skills in `skills/actions/`, `skills/db/`, `skills/dry-rb/`, `skills/testing/`, `skills/views/`, `skills/slices/`.

## Approval Gates

### Context Loaded Gate
Defined in: `load-context`, `hanami-setup`. Context must be discovered before any code.

### Providers Verified Gate
Defined in: `configure-providers`, `hanami-setup`. All providers must boot without errors.

### TDD Gate
Defined in: All code-producing skills. Test must exist, run, and fail before implementation.
