# Contributing to hanakai-yaku

Thank you for your interest in contributing! This document describes how to add a new skill to the repository.

## Adding a New Skill

1. Create a directory under `skills/{category}/{skill-name}/`
2. Add a `SKILL.md` file following the required structure
3. Optionally add `scripts/`, `references/`, or `assets/` subdirectories if needed
4. Update `docs/reference/skill-catalog.md` to include the new skill
5. Run `bin/validate_skills` to ensure the skill passes all checks

## SKILL.md Structure

Every skill MUST include the following sections in order:

1. **YAML Frontmatter** (required fields: `name`, `version`, `license`, `description`, `ecosystem_sources`)
2. **# Title + Core Principle** — Skill name and one-sentence philosophy
3. **## Quick Reference** — Table: scenario → recommended approach
4. **## Core Rules** — Numbered sequential steps the agent must follow
5. **## Common Mistakes** — Table with "Mistake" and "Reality" columns
6. **## Red Flags** — Bullet list of signals that the skill is being violated
7. **## Integration** — Related skills and when to chain to them

Optional sections:
- **## HARD-GATE** — When multi-step checkpoints are required
- **## Rails → Hanami** — When the concept maps from a Rails equivalent
- **## Examples** — Fenced code blocks (may be embedded within Core Rules)

## Review Checklist

Before submitting a pull request:

- [ ] Frontmatter includes all required fields and is valid YAML
- [ ] All required Markdown sections are present and in order
- [ ] Description includes trigger words for agent discovery
- [ ] Examples use Hanami 2.x APIs (not Hanami 1.x or Rails)
- [ ] `ecosystem_sources` lists the correct gem(s) for the DSL covered
- [ ] No duplicate skill names across the repository
- [ ] `bin/validate_skills` passes with zero errors
- [ ] `markdownlint` passes with zero violations

## Code of Conduct

Be respectful and constructive in all interactions.
