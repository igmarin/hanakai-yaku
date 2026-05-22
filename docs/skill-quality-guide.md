# Skill Quality Guide

Quality standards for all skills in the `hanakai-yaku` repository.

## Frontmatter Completeness

Every `SKILL.md` must include:

- `name`: Canonical kebab-case identifier
- `version`: Semver string
- `license`: SPDX identifier (e.g., MIT)
- `description`: One-line description with trigger words
- `ecosystem_sources`: Non-empty array of gem/repo slugs

## Required Sections

Skills must contain (in order):

1. `# Title + Core Principle`
2. `## Quick Reference`
3. `## Core Rules` (skills) or `## Core Process` (workflows)
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

All skills are validated by `bin/validate_skills` which checks:
- YAML frontmatter parses correctly
- Required fields are present and non-empty
- Required Markdown sections exist
- No duplicate skill names

Run before every commit:

```bash
bin/validate_skills
```
