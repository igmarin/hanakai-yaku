---
name: review-slice-boundaries
license: MIT
type: atomic
description: >
  Reviews Hanami slice boundaries for violations — cross-slice coupling, shared internals, import leaks, provider leaks where a provider registers something that should be slice-scoped, and boundary design — producing findings with severity and concrete recommendations, every finding citing the specific file and line as evidence. Use when auditing slice
  architecture or preparing for extraction.
  Trigger words: review slice, slice boundaries, slice coupling, cross-slice,
  boundary review, slice audit, architecture review, bounded context.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Reviewing Slice Boundaries

Audit slice isolation. Every slice should be a self-contained module — dependencies across boundaries must be intentional and through public interfaces.

## Quick Reference

- **Input:** Hanami app with multiple slices.
- **Output:** Findings categorized as Critical, Suggestion, or Note.
- **Checks:** Cross-slice imports, shared internals, provider leaks, route conflicts.
- **Rule:** Every finding cites the specific file and line as evidence.

## HARD-GATE

```text
DO NOT flag intentional cross-slice communication (actions calling other slices' actions).
DO flag any direct import of another slice's repository, relation, or operation.
EVERY finding MUST cite the specific file and line as evidence.
```

## Core Process

1. **Map slices** — list every slice and its public interface (actions).
2. **Scan for violations:**
   - **Direct imports** — Does one slice `require` or reference another slice's repository, relation, operation, or changeset?
   - **Provider leaks** — Does a provider register something that should be slice-scoped?
   - **Route conflicts** — Do two slices define overlapping routes?
   - **Shared internals** — Is business logic duplicated across slices instead of being shared through a shared kernel?
   - **Unintended coupling** — Does a change in Slice A require a change in Slice B for non-public-API reasons?
3. **Classify:**
   - **Critical** — Cross-slice import of internal code. Blocks extraction, breaks isolation.
   - **Suggestion** — Design improvement. Unclear boundary, duplicated logic.
   - **Note** — Observation. Minor inconsistency, future consideration.
4. **Produce** — findings table with severity, evidence, and recommendation.

## Violation Example

A direct import of another slice's internal repository is a **Critical** violation:

```ruby
# slices/main/actions/users/export.rb  ← inside the `main` slice
require 'slices/admin/repositories/user_repo'  # ❌ crosses slice boundary

module Main
  module Actions
    module Users
      class Export < Main::Action
        def handle(request, response)
          repo = Admin::Repositories::UserRepo.new  # ❌ direct internal coupling
          # ...
        end
      end
    end
  end
end
```

The correct approach is to expose data through a public action or shared kernel, not by importing an internal repository directly.

## Output Style

1. **Slice map** — `| Slice | Actions (public API) | Internal modules |`
2. **Findings table** — `| # | Severity | Slice A | Slice B | File | Line | Finding | Recommendation |`
3. **Summary** — count by severity, overall boundary health assessment.
4. **English only** unless user requests otherwise.

### Example Findings Table

| # | Severity | Slice A | Slice B | File | Line | Finding | Recommendation |
|---|----------|---------|---------|------|------|---------|----------------|
| 1 | Critical | `main` | `admin` | `slices/main/actions/users/export.rb` | 2 | Direct `require` of `admin` slice repository `slices/admin/repositories/user_repo` | Expose data via a public `admin` action or move shared logic to a shared kernel |
| 2 | Suggestion | `billing` | `main` | `slices/billing/operations/charge.rb` | 14 | Duplicates `main`'s `EmailValidator` logic inline | Extract `EmailValidator` to `lib/` shared kernel and require from both slices |
| 3 | Note | `reporting` | — | `slices/reporting/providers/db_provider.rb` | 8 | Registers a global `:db` key that shadows the app-level provider | Consider scoping the key to `reporting.db` to avoid potential conflicts |

## Integration

| Skill | When to chain |
|-------|---------------|
| **load-context** | Always first — discover slices before reviewing boundaries |
| **extract-slice** | After extraction, verify no boundary violations were introduced |
| **slice-lifecycle** | Part of the slice development lifecycle agent |
