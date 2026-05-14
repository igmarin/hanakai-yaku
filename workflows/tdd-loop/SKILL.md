---
name: tdd-loop
version: "1.0.0"
license: MIT
description: >
  Use when implementing a Hanami 2.x feature using TDD. Chains plan-tests,
  write-request-spec or write-action-spec, implementation, and code-review.
ecosystem_sources:
  - hanami/hanami
tags:
  - workflows
  - tdd
  - testing
  - development
---

# tdd-loop

Use this workflow when implementing any Hanami 2.x feature using Test-Driven Development.

**Core principle:** Write a failing test → verify it fails for the right reason → implement → verify it passes → review.

---

## Quick Reference

| Step | Skill | Handoff Condition |
|---|---|---|
| 1. Plan tests | `plan-tests` | Test plan written, right test type chosen |
| 2. Write failing test | `write-request-spec` or `write-action-spec` | Test exists and fails for the right reason |
| 3. Implement | — | Test passes |
| 4. Review | `review-code` | No violations found |

---

## Core Process

1. **[Plan Tests]** — Load skill: `plan-tests`
   - Decide: request spec, action unit spec, relation spec, or repository spec?
   - Document the test plan: what behavior, what inputs, what assertions
   - Handoff condition: Test plan is written and reviewed

2. **[Write Failing Test]** — Load skill: `write-request-spec` or `write-action-spec`
   - Write the test that describes the desired behavior
   - Run the test and confirm it FAILS
   - Confirm it fails for the right reason (feature missing, not a typo)
   - **HARD-GATE (TDD)**: Do not proceed until the test fails for the right reason.
   - Handoff condition: Failing test committed or saved

3. **[Implement]** — Write minimal code to make the test pass
   - Start with the simplest implementation that satisfies the test
   - Run the test after each change
   - Refactor only after the test passes
   - Handoff condition: Test passes

4. **[Review]** — Load skill: `review-code`
   - Check for Action responsibility violations
   - Check for DI usage
   - Check for query encapsulation
   - Check for test coverage
   - Handoff condition: No critical violations

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll write the implementation before the test" | TDD means test first. No exceptions. |
| "I'll skip the HARD-GATE and assume the test fails" | Always run the test and verify the failure. A passing "failing test" means the test is wrong. |
| "I'll write all tests at once before implementing" | Write one failing test, implement, then write the next. Incremental progress. |
| "I'll refactor while the test is failing" | Refactor only when tests are green. Red = implement, Green = refactor. |

---

## Red Flags

- Implementation written before any test
- Skipping the HARD-GATE verification
- Multiple failing tests written before any implementation
- Refactoring during red phase
- Tests that pass immediately (indicating wrong test or existing feature)

---

## Integration

| Related Skill | When to chain |
|---|---|
| **plan-tests** | Step 1: Choose the right test type. |
| **write-request-spec** | Step 2: For full-stack HTTP behavior. |
| **write-action-spec** | Step 2: For isolated Action logic. |
| **write-rom-spec** | Step 2: For Relation/Repository testing. |
| **code-review** | Step 4: Review the implementation. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (TDD Workflow) |
|---|---|
| Write controller spec → implement controller | Write request spec → implement Action |
| Write model spec → implement model | Write ROM spec → implement Relation/Repository |
| `rails generate scaffold` then test | No scaffold generator. Write test, then generate components individually. |
| `before_action` callbacks tested implicitly | Explicit auth checks tested in request specs |
