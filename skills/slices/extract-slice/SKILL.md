---
name: extract-slice
license: MIT
description: >
  Extract code from the Hanami app module into a dedicated slice without changing behavior — DO NOT change behavior during extraction, every existing test must pass after the move, identify the bounded context, create the target slice with `create-slice`, move files via `git mv` from old namespace to slices/[slice]/ preserving history, update namespaces from App::X to X (for example App::Payments → Payments), update all imports including `Deps[...]` keys and route definitions, and run the full test suite before and after to verify every existing test still passes. Covers
  identifying extraction boundaries, moving files while preserving history,
  updating imports and dependencies, and verifying the extraction.
  Trigger words: extract slice, extract to slice, move to slice, create slice
  from existing, refactor to slice, modularize.
metadata:
  version: "1.0.0"
  user-invocable: "true"
---
# Extracting Code into a Hanami Slice

Move functionality from the monolithic app module into an isolated slice. Preserve behavior — only change structure.

## Quick Reference

- **Goal:** Increase modularity by isolating a domain into its own slice.
- **Pattern:** Identify bounded context → create slice → move files → update imports → verify.
- **Rule:** Extraction must not change behavior. Run tests before and after.

## HARD-GATE

```text
DO NOT change behavior during extraction. Every existing test must pass after the move.
DO NOT extract code without tests. Characterization tests first if missing.
DO leave the original module empty after extraction — remove dead code.
```

## Core Process

1. **Identify the boundary** — what code belongs together? Look for:
   - Files that share a namespace (e.g., `App::Payments::*`).
   - Operations, repositories, and actions that serve a single domain.
   - Code that only references itself (no cross-domain coupling).
2. **Characterize behavior** — ensure all existing functionality is tested. If not, write characterization tests first. Capture a baseline:
   ```sh
   bundle exec rspec
   ```
3. **Create the target slice** — use `create-slice` to scaffold the new slice structure.
4. **Move files** — relocate from `app/` or `slices/app/` to `slices/<new_slice>/` using `git mv` to preserve history:
   ```sh
   git mv app/actions/payments/ slices/payments/actions/
   git mv app/operations/payments/ slices/payments/operations/
   git mv app/repositories/payments/ slices/payments/repositories/
   ```
   Directory mapping:
   - Actions → `slices/<slice>/actions/`
   - Operations → `slices/<slice>/operations/`
   - Repositories → `slices/<slice>/repositories/`
   - Relations → `slices/<slice>/relations/`
   - Views → `slices/<slice>/views/`
5. **Update namespaces** — change module nesting to the new slice namespace. Example:
   ```ruby
   # Before
   module App
     module Payments
       class CreateOrder < App::Operation
         # ...
       end
     end
   end

   # After
   module Payments
     class CreateOrder < Payments::Operation
       # ...
     end
   end
   ```
6. **Update imports** — any remaining code referencing the old namespace must be updated. Check:
   - `include Deps[...]` keys
   - `require` statements
   - Route definitions
   - Provider registrations
7. **Verify** — run the full test suite. Every test that passed before must pass after:
   ```sh
   bundle exec rspec
   ```
8. **Remove old code** — clean up the original module. Remove empty directories.

## Extended Resources (Progressive Disclosure)

Load these files only when needed:

- **[EXTRACTION_PATTERNS.md](./EXTRACTION_PATTERNS.md)** — Detailed file moving guide, namespace rewriting, common pitfalls.

## Output Style

1. **Extraction plan** — which files move, what namespaces change.
2. **Before/after structure** — directory tree before and after extraction.
3. **Import changes** — every `Deps` key, `require`, and reference that changed.
4. **Verification** — test results before and after extraction.
5. **English only** unless user requests otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **create-slice** | Create the target slice before moving files |
| **test-slice** | Verify the extracted slice works in isolation |
| **review-slice-boundaries** | After extraction, review for boundary violations |
| **slice-lifecycle** | Part of the slice development lifecycle agent |
