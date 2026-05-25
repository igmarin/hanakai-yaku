---
name: slice-lifecycle
license: MIT
description: >
  Orchestrates the full Hanami slice lifecycle: creates the slice, tests it in
  isolation, reviews boundary design, and supports extraction from the app module.
  Use when building a new slice, auditing existing slices, or extracting code
  into a dedicated slice.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when creating a new Hanami slice, auditing slice architecture, or extracting code into a slice"
  phases: "Phase 1: Slice Creation, Phase 2: Slice Testing, Phase 3: Boundary Review, Phase 4: Extraction Support"
  hard_gates: "Tests Pass in Isolation, Boundaries Verified"
  dependencies:
    - source: self
      skills: [create-slice, test-slice, review-slice-boundaries, extract-slice]
  keywords: slice, hanami, lifecycle, create, test, review, extract, boundaries, modular
---
# Slice Lifecycle Agent

Orchestrates the full slice lifecycle: from creation through testing, boundary review, and extraction. Chains four skills through four phases.

## When to Use

- Creating a new Hanami slice and need the full setup verified
- Auditing existing slices for boundary violations
- Extracting monolithic code into a dedicated slice
- Ensuring slice isolation is maintained across the app

## Anti-Patterns

- Do not create a slice without a clear bounded context — one domain per slice
- Do not skip boundary review — coupling accumulates silently
- Do not extract without tests — characterization tests must exist first
- Do not leave extracted code in the app module — remove dead code after extraction

## Agent Phases

### Phase 1: Slice Creation

1. Activate **slices/create-slice**: Scaffold the new slice with proper structure.
2. Define the slice's public interface (actions).
3. Set up the slice's internal structure (operations, repositories, relations, views).

**Quality Check:**
- Slice directory structure follows Hanami conventions.
- Slice has a clear, single responsibility.
- Public interface is defined (actions only).

---

### Phase 2: Slice Testing

1. Activate **slices/test-slice**: Set up isolated test infrastructure.
2. Write or verify action specs at the HTTP boundary.
3. Write or verify operation specs with stubbed dependencies.
4. Write or verify repository specs against test data.

**HARD GATE — Tests Pass in Isolation:**
```text
All slice tests MUST pass with only the target slice loaded.
DO NOT proceed if cross-slice dependencies cause test failures.
Fix isolation issues before continuing.
```

---

### Phase 3: Boundary Review

1. Activate **slices/review-slice-boundaries**: Audit all slices for boundary violations.
2. Check for direct imports of another slice's internal modules.
3. Verify cross-slice communication uses public interfaces only.
4. Classify findings as Critical, Suggestion, or Note.

**HARD GATE — Boundaries Verified:**
```text
NO Critical boundary violations may remain unaddressed.
Every Critical finding must have a resolution plan.
DO NOT proceed with unaddressed isolation breaches.
```

---

### Phase 4: Extraction Support

1. Activate **slices/extract-slice**: Move code from the app module into the target slice.
2. Follow the extraction process: characterize → create → move → update → verify → remove.
3. Run the full test suite after extraction — every test that passed before must pass after.

---

## Error Recovery

| Scenario | Recovery |
|----------|----------|
| Slice creation fails (missing directory) | Verify the parent `slices/` directory exists. Check permissions. |
| Tests fail due to cross-slice imports | Identify the violating import. Replace with public API call or refactor. |
| Boundary review finds critical violation | Document the finding, assign an owner, create a resolution plan. |
| Extraction breaks existing tests | Check namespace changes. Verify Deps keys and require paths were updated. |
| Slice has no clear bounded context | Ask: "What single domain does this slice serve?" If unclear, reconsider extraction. |

## Output Style / Report

```markdown
## Slice Lifecycle Complete: [Slice Name]

### Phase 1 — Creation
- Slice: `slices/[name]/`
- Actions: [N] defined
- Internal structure: operations, repositories, relations, views

### Phase 2 — Testing
- Action specs: [N] passing
- Operation specs: [N] passing
- Repository specs: [N] passing
- Isolation: Verified / Issues Found

### Phase 3 — Boundary Review
- Critical findings: [N]
- Suggestions: [N]
- Notes: [N]
- Overall health: Good / Needs attention

### Phase 4 — Extraction (if applicable)
- Files moved: [N]
- Namespaces updated: [N]
- Tests passing after extraction: [N]/[N]
```
