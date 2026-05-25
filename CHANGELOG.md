# Changelog

## [Unreleased]

### Fixed
- Fixed agent dependencies syntax (from string to YAML list of hashes) in `hanami-setup` and `slice-lifecycle` agents to pass ecosystem consistency audit.
- Added `new_name` fields to `deprecated_skills` in `tile.json` to resolve name redirects correctly.

## [0.3.0] - 2026-05-24

### Breaking Changes

- **Removed 2 skills replaced by `ruby-core-skills` process skills:**
  - `refactor-code` → use `refactor-process` from `ruby-core-skills`
  - `plan-tests` → use `test-planning-process` from `ruby-core-skills`

### Added

- `depends_on: ["igmarin/ruby-core-skills"]` in `tile.json`
- `deprecated_skills` section in `tile.json` (2 entries) for backward compatibility
- Cross-repo dependency declarations in `tdd-loop` agent frontmatter
- Process skill references in `review-code` and `review-security` Integration tables
- Updated `AGENTS.md` with complete skill catalog (was previously partial)

### Migration Guide

1. Install `ruby-core-skills` alongside `hanakai-yaku`
2. Generic refactoring discipline → `refactor-process` (from core)
3. Generic test planning → `test-planning-process` (from core)
4. Hanami-specific test writing skills (`write-request-spec`, `write-action-spec`, `write-rom-spec`) are unchanged
5. Check user-installed copies for stale references:
   ```bash
   grep -r "refactor-code\|plan-tests" ~/.claude/ .agents/ AGENTS.md CLAUDE.md GEMINI.md 2>/dev/null
   ```

## 0.2.0 — Slice Lifecycle + dry-rb Patterns

- `create-operation` — dry-operation/dry-transaction for business workflows
- `create-validation-contract` — dry-validation contracts for type-safe input
- `create-changeset` — ROM changesets for write operations
- `test-slice` — Isolated slice testing with boundary verification
- `extract-slice` — Extract code from app module into dedicated slices
- `review-slice-boundaries` — Audit slice isolation and coupling
- `slice-lifecycle` agent — Full slice lifecycle: Create → Test → Review → Extract
- Now 37 skills and 10 agents total

## 0.1.0 — Initial Release

- `load-context` — Load Hanami app structure before coding
- `configure-providers` — Set up Hanami providers, settings, and .env
- `implement-di` — Dependency injection patterns with dry-system
- `hanami-setup` agent — Project onboarding workflow
- Infrastructure: tile.json, agents.json, docs/, CONTEXT.md, AGENTS.md

