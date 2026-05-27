---
name: test-slice
license: MIT
description: >
  Test a Hanami slice in isolation — write the test first to verify it fails for the right reason, load only the slice under test with `:slice` RSpec metadata tag, mock cross-slice dependencies, never reach into another slice's internals, a slice test must NOT depend on another slice booting, test the public interface through action specs with stubbed operations, operation specs with test doubles through constructor, repository specs against a test database, and integration specs across the full slice workflow, and when testing cross-slice interactions, stub the public interface or use shared test helpers rather than instantiating another slice's internals. Covers slice test
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

> **Pattern reference:** See [SLICE_TEST_PATTERNS.md](./SLICE_TEST_PATTERNS.md) for slice-isolated test helpers, database strategies, action/operation/integration spec patterns, and cross-slice mocking.

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
   **Validation checkpoint:** confirm the slice loads before writing specs:
   ```bash
   bundle exec rspec spec/slices/api/ --dry-run
   # Expect: 0 errors, all examples collected. Fix any boot errors before proceeding.
   ```
2. **Action specs** — test the HTTP boundary. Stub injected operations:
   ```ruby
   RSpec.describe Api::Actions::Users::Create, :slice do
     let(:create_user) { instance_double(Users::CreateUser) }
     let(:action) { described_class.new(create_user:) }
   end
   ```
3. **Operation specs** — test business logic with stubbed repositories and services:
   ```ruby
   RSpec.describe Api::Operations::Users::Create, :slice do
     let(:repo) { instance_double(Api::Repositories::UserRepo) }
     subject(:operation) { described_class.new(user_repo: repo) }

     it "creates a user and returns a success result" do
       allow(repo).to receive(:create).and_return(double(id: 42, email: "a@example.com"))
       result = operation.call(email: "a@example.com", name: "Alice")
       expect(result).to be_success
     end
   end
   ```
4. **Repository specs** — test query methods against a test database. No stubs needed. Requires a running test DB and `DatabaseCleaner` (or equivalent) configured in `spec/support/database.rb`:
   ```ruby
   RSpec.describe Api::Repositories::UserRepo, :slice, :db do
     subject(:repo) { described_class.new }

     it "finds a user by email" do
       repo.create(email: "b@example.com", name: "Bob")
       user = repo.find_by_email("b@example.com")
       expect(user.email).to eq("b@example.com")
     end
   end
   ```
5. **Integration specs** — test a full slice workflow (action → operation → repository) within the slice's boundary. Boot only the target slice, use real collaborators inside it, and assert on the HTTP response or returned result:
   ```ruby
   RSpec.describe "Api users flow", :slice, :db do
     it "creates and retrieves a user" do
       result = Api::Actions::Users::Create.new.call(params: { email: "c@example.com", name: "Carol" })
       expect(result[:status]).to eq(201)
     end
   end
   ```
6. **Cross-slice testing** — test interactions between slices through their public API only. When a slice boundary must be exercised, stub the public interface or use a shared test helper rather than instantiating the other slice's internals:
   ```ruby
   # Never: Api::Repositories::UserRepo.new.find(id) from another slice
   # Prefer: stub the public action
   let(:users_api) { instance_double(Api::Actions::Users::Show) }
   before { allow(users_api).to receive(:call).and_return({ status: 200, user: { id: 1 } }) }

   # Or: extract shared test helpers to spec/support/slices/api_helpers.rb
   # and include them in both slices' specs.
   ```

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
