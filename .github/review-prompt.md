# Hanami Skills Code Review

You are reviewing a pull request for hanakai-yaku — a curated library of 35 atomic skills
and 10 personas for Hanami 2.x, dry-rb, and ROM Ruby development.

## Review Focus Areas

### 1. Skill Structure & Consistency
- Does each skill follow the 6-section body format (Frontmatter, Quick Reference,
  HARD-GATE, Core Process, Output Style, Integration)?
- Are YAML frontmatter fields (name, description) complete and accurate?
- Do skills correctly reference ruby-core-skills process dependencies
  (tdd-process, refactor-process, review-process)?

### 2. Hanami/dry-rb/ROM Conventions (for any Ruby code in skills/evals/scripts)
- `frozen_string_literal: true` on line 1 of every .rb file
- Hanami slice structure respected (actions/, repos/, relations/, views/)
- ROM Relations and Repos follow established patterns
- dry-system DI via `Deps` mixin (no manual require/instantiation)
- dry-monads result pattern for operations (no bare exceptions)
- YARD documentation on all public interfaces (@param, @return, @raise)

### 3. Test Coverage & TDD Discipline
- Tests gate implementation (Red-Green-Refactor)
- Request specs for actions, unit specs for repos/relations
- Edge cases and error paths covered
- Synthetic test data only (no real production values)

### 4. Documentation Quality
- SKILL.md files are clear, actionable, and self-contained
- Trigger words accurately describe when to use the skill
- Persona chaining references are accurate (predecessor/successor skills)
- CONTEXT.md domain glossary kept in sync with new concepts

### 5. Process Adherence
- TDD workflow enforced for all code-producing skills
- No implementation before failing test exists
- Security considerations addressed for Hanami patterns (params validation,
  SQL parameterization via ROM, halt/error handling)

## Output Format

For each finding, provide:
- **Severity**: Critical / Suggestion / Nitpick
- **File & Line**: Where the issue is
- **Issue**: What's wrong
- **Suggestion**: How to fix it

Focus on actionable feedback. Skip style-only nits if a linter handles them.
