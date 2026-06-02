# Skill Quality Guide

Quality standards for all skills in the `hanakai-yaku` repository.

## Frontmatter Completeness

Every `SKILL.md` must include:

- `name`: Canonical kebab-case identifier
- `type`: `atomic` (standalone skill), `persona` (orchestrating workflow), or `catalog` (root)
- `version`: Semver string
- `license`: SPDX identifier (e.g., MIT)
- `description`: One-line description with trigger words

Optional fields:
- `ecosystem_sources`: Array of gem/repo slugs (recommended for discovery)

## Required Sections

Skills must contain (in order):

1. `# Title + Core Principle`
2. `## Quick Reference`
3. `## Core Rules` (atomic skills) or `## Core Process` (personas)
4. `## Common Mistakes`
5. `## Red Flags`
6. `## Integration`

Optional sections:
- `## HARD-GATE` — For TDD or checkpoint enforcement
- `## Rails → Hanami` — For skills that map from Rails
- `## Examples` — Fenced code blocks

## Trigger Word Coverage

The `description` field must include:
- Concrete nouns ("migration", "action", "repository")
- Action verbs ("creating", "reviewing", "fixing")
- Error symptoms ("N+1", "fat model", "flaky tests")

Do NOT summarize the workflow in the description. This causes models to skip reading the body.

## Process Step Atomicity

Each step in `## Core Rules` or `## Core Process` must:
- Be a single action
- Be verifiable (can check if it's done)
- Include an example or concrete instruction

## Example Correctness

- All code examples must use Hanami 2.x APIs
- No Hanami 1.x or Rails syntax in Hanami-specific skills
- Fenced code blocks must specify the language

## Pitfall Specificity

`## Common Mistakes` entries must:
- State the mistake clearly
- Explain why it's wrong
- Show the correct alternative

## Testing Skills

Testing skills must include a `## HARD-GATE` section enforcing:
- Write failing test before implementation
- Verify failure is for the right reason
- No exceptions

## Validation

Before submitting a PR, verify:

1. **Frontmatter**: All required fields are present (`name`, `type`, `version`, `license`, `description`)
2. **YAML**: Frontmatter parses without errors
3. **Sections**: All required Markdown sections exist
4. **Names**: No duplicate skill names across the repository
5. **Registry**: `directory.json` includes the new skill or persona
6. **markdownlint**: Passes with zero violations

```bash
markdownlint skills/ --ignore node_modules
```
