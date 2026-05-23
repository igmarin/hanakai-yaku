---
name: test-slice
license: MIT
description: >
  Tests a Hanami slice in isolation — verifying boundaries, loading only the
  slice under test, and mocking cross-slice dependencies. Covers slice test
  setup, isolation strategies, and integration testing across slices.
  Trigger words: test slice, slice test, isolate slice, slice isolation,
  test boundaries, slice specs, Hanami slice testing.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Testing a Hanami Slice

Test a slice in isolation — verify its behavior without loading the full app.

## Quick Reference

- **Goal:** Test a slice's public interface. Never reach into another slice's internals.
- **Isolation:** Load only the slice under test. Mock cross-slice dependencies.
- **Scope:** Action specs, operation specs, repository specs, integration specs.
- **Rule:** A slice test must NOT depend on another slice booting.

## HARD-GATE

```text
Write test → Run test → Verify it FAILS → Implement → Verify it PASSES
DO NOT test private methods or internal slice structure.
DO NOT load another slice in a slice's isolated test. Mock cross-slice calls.
```

## Core Process

1. **Slice test setup** — configure RSpec to load only the target slice:
   ```ruby
   # spec/slices/api/slice_helper.rb
   require "hanami/rspec"

   RSpec.configure do |config|
     config.before(:suite) do
       Hanami.app.prepare(:api) # load only the :api slice
     end
   end
   ```
2. **Action specs** — test the HTTP boundary. Stub injected operations:
   ```ruby
   RSpec.describe Api::Actions::Users::Create, :slice do
     let(:create_user) { instance_double(Users::CreateUser) }
     let(:action) { described_class.new(create_user:) }
   end
   ```
3. **Operation specs** — test business logic with stubbed repositories and services.
4. **Repository specs** — test query methods against a test database. No stubs needed.
5. **Integration specs** — test a full slice workflow (action → operation → repository) within the slice's boundary.
6. **Cross-slice testing** — test interactions between slices through their public API only:
   ```ruby
   # Never: Api::Repositories::UserRepo.new.find(id) from another slice
   # Prefer: stubbing the public action or using a shared test helper
   ```

## Extended Resources (Progressive Disclosure)

Load these files only when needed:

- **[SLICE_TEST_PATTERNS.md](./SLICE_TEST_PATTERNS.md)** — Test isolation setup, database strategies, cross-slice mocking patterns.

## Output Style

1. **Slice helper** — the test setup file for the slice.
2. **Action spec** — test the HTTP boundary with stubbed operations.
3. **Operation spec** — test business logic with stubbed dependencies.
4. **Repository spec** — test queries against test data.
5. **English only** unless user requests otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **create-slice** | Test immediately after creating a new slice |
| **plan-tests** | Plan the test strategy before writing slice specs |
| **slice-lifecycle** | Part of the slice development lifecycle agent |
