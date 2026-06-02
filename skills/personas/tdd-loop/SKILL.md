---
name: tdd-loop
license: MIT
type: persona
description: >
  Use when implementing a Hanami 2.x feature, Hanami action, Hanami slice, or any Hanami controller logic using test-driven development (TDD / red-green-refactor). Orchestrates test planning, generates request specs or action unit specs, drives the implementation of Hanami action classes and route configurations, and performs a final code review. Use when starting a new Hanami feature from scratch, adding integration tests for an existing Hanami action, or following a red-green-refactor cycle for any Hanami 2.x component.
metadata:
  ecosystem_sources:
  - hanami/hanami
  tags:
  - personas
  - tdd
  - testing
  - development
  version: 1.0.0
  dependencies:
    - source: self
      skills: [load-context, write-request-spec, review-code]
    - source: ruby-core-skills
      skills: [tdd-process, test-planning-process]
---

# tdd-loop

Use this workflow when implementing any Hanami 2.x feature using Test-Driven Development.

**Core principle:** Write a failing test → verify it fails for the right reason → implement → verify it passes → review.

---

## Quick Reference

| Step | Skill | Handoff Condition |
|---|---|---|
| 1. Plan tests | `test-planning-process` *(from ruby-core-skills)* | Test plan written, right test type chosen |
| 2. Write failing test | `write-request-spec` or `write-action-spec` | Test exists and fails for the right reason |
| 3. Implement | — | Test passes |
| 4. Review | `review-code` | No violations found |

---

## Core Process

1. **[Plan Tests]** — Load skill: `test-planning-process` *(from ruby-core-skills)*
   - Decide: request spec, action unit spec, relation spec, or repository spec?
   - Document the test plan: what behavior, what inputs, what assertions
   - Handoff condition: Test plan is written and reviewed

2. **[Write Failing Test]** — Load skill: `write-request-spec` or `write-action-spec`
   - Write the test that describes the desired behavior
   - Run the test: `bundle exec rspec spec/requests/...` (request spec) or `bundle exec rspec spec/actions/...` (action spec)
   - Confirm it FAILS and fails for the right reason (feature missing, not a typo)
   - **HARD-GATE (TDD — `tdd-process` *(from ruby-core-skills)*)**: Do not proceed until the test fails for the right reason.
   - Handoff condition: Failing test committed or saved

3. **[Implement]** — Write minimal code to make the test pass
   - Start with the simplest implementation that satisfies the test
   - Run `bundle exec rspec` after each change
   - Refactor only after the test passes
   - Handoff condition: Test passes

4. **[Review]** — Load skill: `review-code`
   - Check for Action responsibility violations
   - Check for DI usage
   - Check for query encapsulation
   - Check for test coverage
   - Handoff condition: No critical violations

---

## Minimal Example

**Failing request spec** (`spec/requests/posts/create_spec.rb`):
```ruby
RSpec.describe "POST /posts", type: :request do
  it "creates a post and redirects" do
    post "/posts", params: { post: { title: "Hello" } }
    expect(last_response.status).to eq(302)
  end
end
```
Run: `bundle exec rspec spec/requests/posts/create_spec.rb` → expect a failure such as `ActionNotFound` or `404`.

**Minimal implementation** — generate the action and register the route:
```ruby
# app/actions/posts/create.rb
module MyApp
  module Actions
    module Posts
      class Create < MyApp::Action
        def handle(request, response)
          response.redirect_to "/posts"
        end
      end
    end
  end
end
```
Run: `bundle exec rspec spec/requests/posts/create_spec.rb` → expect green.

---

## Common Mistakes & Red Flags

| Mistake / Red Flag | Why it matters |
|---|---|
| Implementation written before any test | TDD means test first. No exceptions. |
| Skipping the HARD-GATE — assuming the test fails without running it | A passing test without running it first doesn't verify the assertion works — run it to confirm RED |
