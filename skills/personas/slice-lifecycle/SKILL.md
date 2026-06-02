---
name: slice-lifecycle
license: MIT
type: persona
description: >
  Orchestrates the full Hanami slice lifecycle: creates the slice, tests it in
  isolation, reviews boundary design, and supports extraction from the app module.
  Use when building a new Hanami slice, auditing existing slices for bounded context
  violations, extracting monolithic code into a modular architecture, or enforcing
  slice generator conventions. Trigger terms: bounded context, Hanami module, modular
  architecture, slice boundaries, slice extraction, slice generator.
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
# Slice Lifecycle Persona

Orchestrates the full slice lifecycle: from creation through testing, boundary review, and extraction. Chains four phases with hard gates between them.

## Anti-Patterns

- Do not create a slice without a clear bounded context — one domain per slice
- Do not skip boundary review — coupling accumulates silently
- Do not extract without characterization tests in place first
- Do not leave extracted code in the app module — remove dead code after extraction

## Persona Phases

### Phase 1: Slice Creation

1. Scaffold the new slice using the generator:
   ```bash
   bundle exec hanami generate slice <name>
   ```
   Expected output structure:
   ```
   slices/
   └── <name>/
       ├── action.rb
       ├── actions/
       ├── lib/
       │   └── <name>/
       │       ├── operations/
       │       ├── repositories/
       │       └── views/
       └── config/
   ```
2. Define the slice's public interface (actions).
3. Set up the slice's internal structure (operations, repositories, relations, views).

**Quality Check:**
- Slice directory structure follows Hanami conventions.
- Slice has a clear, single responsibility.
- Public interface is defined (actions only).

---

### Phase 2: Slice Testing

1. Set up isolated test infrastructure.
2. Write or verify action specs at the HTTP boundary.
3. Write or verify operation specs with stubbed dependencies.
4. Write or verify repository specs against test data.

Example action spec (RSpec):
```ruby
# spec/slices/<name>/actions/index_spec.rb
RSpec.describe <Name>::Actions::Index do
  let(:app) { <Name>::Slice.rack_app }

  it "returns 200" do
    get "/"
    expect(last_response.status).to eq(200)
  end
end
```

Run the slice in isolation:
```bash
HANAMI_SLICE=<name> bundle exec rspec spec/slices/<name>/
```

**HARD GATE — Tests Pass in Isolation:**
```text
All slice tests MUST pass with only the target slice loaded.
DO NOT proceed if cross-slice dependencies cause test failures.
Fix isolation issues before continuing.
```

---

### Phase 3: Boundary Review

1. Audit all slices for boundary violations.
2. Check for direct imports of another slice's internal modules.
3. Verify cross-slice communication uses public interfaces only.
4. Classify findings as Critical, Suggestion, or Note.

**Boundary Violation vs. Valid Cross-Slice Call:**
```ruby
# ❌ Direct import — VIOLATION
require "slices/billing/lib/billing/repositories/invoice_repo"

# ✅ Public API call — CORRECT
Hanami.app["billing.actions.invoices.create"].call(params)
```

**HARD GATE — Boundaries Verified:**
```text
NO Critical boundary violations may remain unaddressed.
Every Critical finding must have a resolution plan.
DO NOT proceed with unaddressed isolation breaches.
```

---

### Phase 4: Extraction Support

1. Move code from the app module into the target slice.
2. Follow the extraction process: characterize → create → move → update → verify → remove.
3. Update `Deps` keys and require paths after moving files:
   ```ruby
   # Before (app module)
   include Deps["repositories.users"]

   # After (inside target slice)
   include Deps["<name>.repositories.users"]
   ```
4. Run the full test suite after extraction — every test that passed before must pass after:
   ```bash
   bundle exec rspec
   ```

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
