# Plan 4: Flatten Agents into Skills — agnostic-planning-skills

**Status:** Completed
**Scope:** igmarin/agnostic-planning-skills (Phase 1 of 4 repos)
**Next:** Copy this plan to hanakai-yaku, rails-agent-skills, ruby-core-skills

## Core Decisions (from grill session)

| Decision | Outcome |
|----------|---------|
| Target directory | `skills/personas/` — not `skills/workflows/` |
| Type field | Explicit `type: atomic` and `type: persona` in frontmatter |
| Requirements-clarifier | New atomic skill at `skills/requirements-clarifier/` (not a persona) |
| Repo-agnostic | requirements-clarifier feeds into product-owner and tech-lead personas |
| OpenCode support | `.opencode/agents/` wrappers with `mode: subagent` + tool restrictions |
| Cross-LLM | Canonical source is `SKILL.md` — `.opencode/agents/` is opencode-specific |
| Persona tooling | Orchestrator personas: allow edit/write, deny bash |
| Persona tooling | Read-only personas: deny edit, write, bash (requirements-clarifier) |
| Future repos | rails-agent-skills → `skills/personas/`; hanakai-yaku → `skills/personas/` |
| New roles (future) | architect-designer → ruby-core-skills; test-automation-engineer → ruby-core-skills |

## Vocabulary

| Old Term | New Term | Definition |
|----------|----------|------------|
| Agent | Persona | A role-based workflow (orchestrates atomic skills) |
| Agent directory | `skills/personas/` | Location for persona SKILL.md files |
| Skill | Atomic Skill | Single capability with `type: atomic` |
| Orchestrator | Orchestrating Persona | A persona that chains atomic skills |
| agents.json | (deleted) | Merged into directory.json |
| AGENTS.md | (deleted) | Content merged into CLAUDE.md / GEMINI.md |
| tile.json | directory.json | Old tessl registry → new `directory.json` format |

---

## PHASE 1 — Add `type: atomic` to existing skills

Add `type: atomic` to the YAML frontmatter of every existing atomic skill. Root SKILL.md gets `type: catalog`.

- [x] All atomic skill SKILL.md files
- [x] Root `SKILL.md` — `type: catalog`

---

## PHASE 2 — Move agents to skills/personas/

- [x] Move all `agents/<name>/SKILL.md` → `skills/personas/<name>/SKILL.md`
- [x] Add `type: persona` to frontmatter
- [x] Rename title from "Agent" → "Persona"

---

## PHASE 3 — Create skills/requirements-clarifier/ (if applicable)

- [x] New atomic skill for transforming vague requests into specs (agnostic-planning-skills only)

---

## PHASE 4 — Create `.opencode/agents/` wrappers

Create `mode: subagent` wrappers for opencode users. One per persona, with:

- `prompt: "{file:./skills/personas/<name>/SKILL.md}"` referencing canonical source
- `permission` block: orchestrator personas get `edit/write: allow, bash: deny`; read-only personas (requirements-clarifier) get `edit/write/bash: deny`

- [x] One `.md` file per persona in `.opencode/agents/`

---

## PHASE 5 — Delete obsolete files

- [x] Delete `agents/` directory
- [x] Delete `agents.json` (entries merged into `directory.json`)
- [x] Delete `AGENTS.md` (content merged into CLAUDE.md / GEMINI.md)

---

## PHASE 6 — Update directory.json

- [x] Add all personas under `"skills"` key
- [x] Add new atomic skills (e.g. requirements-clarifier)
- [x] Bump major version

---

## PHASE 7 — Update root SKILL.md

- [x] Update description counts (skills + personas)
- [x] Rename "Agents" section to "Personas"
- [x] Add any new skills to Quick Reference
- [x] Remove `agents.json` references

---

## PHASE 8 — Update documentation

- [x] `README.md` — counts, tables, terminology
- [x] `CLAUDE.md` / `GEMINI.md` — agent → persona, add new skills
- [x] `docs/architecture.md` — directory tree, skill types
- [x] `docs/persona-guide.md` → `docs/persona-guide.md` — rename + content update
- [x] `docs/calling-skills.md` — agents → personas
- [x] `docs/reference/skill-catalog.md` — agents → personas, add new skills
- [x] `docs/index.md` — counts, terminology
- [x] `CONTRIBUTING.md` — remove tile.json references, update paths
- [x] `CHANGELOG.md` — major version entry

---

## PHASE 9 — Tessl plugin migration

- [x] Update `.tessl-plugin/plugin.json` to use `"skills": "./skills/"` (auto-discovery)
- [x] Rename `tessl-evals/` → `evals/` (required for plugin eval mode)
- [x] Run `tessl project repair` to confirm project link
- [x] Update `tile.json` references in docs to `directory.json`

---

## PHASE 10 — CI workflow fixes (all repos)

The `anomalyco/opencode/github@latest` action was failing with "Failed to parse JSON" errors.

- [x] Pin from `@latest` → `@github-v1.2.24` (avoid pulling broken builds mid-CI)
- [x] Add `GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}` env to both workflows
- [x] Add `use_github_token: true` to both workflows
- [x] Fix PR review workflow: `pull-requests: read` → `pull-requests: write` (needed to post comments)

Applied to: agnostic-planning-skills, ruby-core-skills, rails-agent-skills, hanakai-yaku

---

## PHASE 11 — Description optimization (eval-driven)

Run Tessl evals, identify skills with <80% baseline score, and fix their `description` first sentence.

### Rules applied:

1. **Lead with non-negotiable rules** not high-level summaries
2. **Pack critical constraints before the first `.`** — use commas, em dashes, parentheses
3. **Persona strategy**: hard gates first, not what the persona does
4. **Eliminate `...` followed by space** (triggers regex split)

### Results (agnostic-planning-skills, sonnet-4-6):

| Skill | Before | After | Delta | Fix |
|-------|--------|-------|-------|-----|
| Identify Risks | 76% | 94% | **+18** | Led with "do NOT fabricate, every risk MUST reference evidence, verify ratings" |
| Generate Status Report | 90% | 92% | +2 | Tightened never-fabricate constraint |
| Review Prd | 97% | 99% | +2 | N/A (already high) |
| Delivery Lead* | 19% | N/A | — | Packed 3 hard gates + phase ordering |
| Product Owner* | 62% | N/A | — | Packed 4 hard gates into first sentence |
| Project Manager* | 37% | N/A | — | Packed 3 hard gates + constraints |
| Tech Lead* | 84% | N/A | — | Added evidence citation + severity classification |
| **Baseline avg** | **81%** | **93%** | **+12** | With context avg: 100% |

*\*Persona skills use Tessl auto-generated evals — no local `evals/` scenarios*

### Known issue:

`claude:glm-5.1` produces false 0% baseline scores. Always use `claude:claude-sonnet-4-6` for evals:

```bash
tessl eval run . --agent "claude:claude-sonnet-4-6"
```

### Ceiling:

Some rules resist first-sentence compression — e.g., Plan Tickets instruction-4 ("do not re-plan if a plan already exists") is a nuanced conditional. Accept 70-75% for these.

---

## PHASE 12 — Post-merge fixes (PR review findings)

- [x] `CONTRIBUTING.md` — `tile.json` → `directory.json` on line 15
- [x] `integration-matrix.md` — "Complete Agent Loops" → "Complete Persona Loops"
- [x] `integration-matrix.md` — Quick Decision Matrix code block unclosed + missing labels + missing Checkpoints & Gates + See Also
- [x] `skill-catalog.md` — "All 11 skills" → "All 10 skills" for delivery-lead
- [x] `.opencode/agents/delivery-lead.md` — add clarifying permission comment

---

## Reusable Checklist for Other Repos

Copy this plan and run through these steps for each target repo:

### Structural migration
- [ ] Add `type: atomic` to all existing atomic skills
- [ ] Move agents/ → skills/personas/ with `type: persona`
- [ ] Delete `agents/`, `agents.json`, `AGENTS.md`
- [ ] Update `directory.json` to include personas
- [ ] Update root SKILL.md, README, CLAUDE.md, GEMINI.md
- [ ] Create `.opencode/agents/` wrappers (if opencode users exist)

### Tessl plugin
- [ ] Ensure `.tessl-plugin/plugin.json` uses `"skills": "./skills/"`
- [ ] Rename `tessl-evals/` → `evals/` if exists
- [ ] Run `tessl project repair` to verify link

### CI workflows
- [ ] Pin `anomalyco/opencode/github@latest` → `@github-v1.2.24`
- [ ] Add `GITHUB_TOKEN` env + `use_github_token: true`
- [ ] Fix `pull-requests: read` → `pull-requests: write` in PR review workflow

### Description optimization
- [ ] Run `tessl eval run . --agent "claude:claude-sonnet-4-6"`
- [ ] Check baseline scores — fix any <80%
- [ ] Apply persona hard-gate strategy for any persona skills
- [ ] Run evals again to validate
- [ ] Update `docs/skill-description-strategy.md` with results

---

## Summary of Operations (agnostic-planning-skills)

| Action | Files |
|--------|-------|
| Add `type:` field | 11 SKILL.md files |
| Move agents → personas | 4 files |
| Create new atomic skill | 1 file (requirements-clarifier) |
| Create .opencode/agents wrappers | 5 files |
| Delete obsolete | 1 dir + 2 files |
| Update directory.json | 1 file |
| Update documentation | ~10 files |
| Fix CI workflows | 2 files (×4 repos) |
| Fix PR review findings | 4 files |
| Optimize descriptions | 7 skills (4 personas + 3 atomic) |
| **Total** | **~50 file operations** |
