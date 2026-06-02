# Changelog

## [0.4.0] - 2026-06-01

### Breaking Changes
- **Renamed "agents" → "personas"** across all docs, configs, and metadata
- **Moved `agents/` → `skills/personas/`** — all agent SKILL.md files now live under `skills/personas/<name>/`
- **Deleted `AGENTS.md`**, `agents.json`, and `agents/` directory
- **Added `type:` frontmatter** — `type: atomic` (35 skills), `type: persona` (10 personas), `type: catalog` (root SKILL.md)

### Added
- `type: atomic` to all 35 atomic skill SKILL.md files
- `type: persona` to all 10 persona SKILL.md files (in `skills/personas/`)
- `type: catalog` to root SKILL.md
- `.opencode/agents/` wrappers — 10 subagent wrappers with `mode: subagent` + permission blocks
- `docs/persona-guide.md` — Persona reference guide with phases, hard gates, and invocation docs
- Personas to `directory.json` — all 10 personas now listed in the skill registry

### Changed
- `.tessl-plugin/plugin.json` — switched from explicit skill array to `"skills": "./skills/"` auto-discovery
- `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json` — version synced to 0.4.0
- `CLAUDE.md`, `GEMINI.md`, `README.md` — agent→persona terminology throughout
- `docs/` — all references updated (skill-catalog, integration-matrix, index, architecture, calling-skills, using-skills-guide)
- Updated skill descriptions for `write-request-spec` and `extract-slice` to improve Tessl eval baseline scores

### Removed
- `agents/` directory (10 files moved to `skills/personas/`)
- `agents.json` (entries merged into `directory.json`)
- `AGENTS.md` (content merged into CLAUDE.md/GEMINI.md)
- `tessl-evals/` directory (replaced by `evals/` for Tessl plugin auto-discovery)

### Fixed
- CI workflows — pinned `anomalyco/opencode/github@latest` → `@github-v1.2.24`, added `GITHUB_TOKEN` env + `use_github_token: true`, fixed `pull-requests: read` → `write` in review workflow
- Malformed headings in `hanami-setup` and `slice-lifecycle` persona SKILL.md (`# # Title` → `# Title`)

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

