# Using Skills and Personas

This guide explains how to compose atomic skills into personas, choose the right skill for a task, and chain skills together for common development scenarios.

---

## Philosophy: Skills as Building Blocks

Each skill in `hanakai-yaku` is **atomic** — it covers one specific task completely. Personas are **orchestrations** — they sequence skills in a meaningful order.

**Analogy**: Skills are musical notes. Personas are songs. You can play a song (workflow) or improvise by combining notes (ad-hoc skill chaining).

---

## Decision Tree: Which Skill Do I Use?

### I need to add a database table

```text
write-migration (create the table)
  → define-relation (map the table to ROM)
    → define-entity (create the data structure)
      → create-repository (add persistence methods)
        → write-rom-spec (test the repository)
```

### I need to add an HTTP endpoint

```text
create-action (implement the endpoint)
  → validate-params (add input validation)
    → handle-errors (add error responses)
      → create-view (add HTML rendering, if needed)
        → write-request-spec (test the endpoint)
```

### I need to change an existing table

```text
write-migration (add the column)
  → add-table-column workflow (full cascade: migration → relation → entity → repository → tests)
```

### I need to create a new bounded context

```text
create-new-slice workflow (generate → routes → configure → DI → tests)
```

### I need to implement a full CRUD resource

```text
build-crud-resource workflow (entity → relation → repository → actions → views → tests → review)
```

---

## Common Composition Patterns

### Pattern 1: Data-First (New Resource)

Always start with the data layer when building something new.

```text
1. define-entity        # What does the data look like?
2. write-migration      # How is it stored?
3. define-relation      # How do we query it?
4. create-repository    # How do we persist it?
5. create-action        # How do users access it?
6. write-request-spec   # Does it work end-to-end?
```

**Why this order?** Each layer depends on the one below it. Actions need Repositories. Repositories need Relations. Relations need tables. Entities define the data contract.

### Pattern 2: Endpoint-First (API Addition)

When adding an endpoint to an existing resource, start from the HTTP layer.

```text
1. create-action        # Define the endpoint
2. validate-params      # Validate input
3. inject-dependencies  # Wire in existing repositories
4. handle-errors        # Handle failure cases
5. write-request-spec   # Test the endpoint
```

**Why this order?** The data layer already exists. You're adding a new access pattern, not new data.

### Pattern 3: Refactoring Loop

When cleaning up existing code, alternate between review and refactor.

```text
1. review-code          # Identify issues
2. refactor-code        # Fix one category at a time
3. write-request-spec   # Add missing tests
4. review-code          # Verify fixes
```

**Rule**: Never refactor without a characterization test. If no test exists, write one first.

### Pattern 4: Validation-Heavy Feature

When user input is complex, lead with validation.

```text
1. validate-params      # Define input constraints
2. handle-result-pattern  # Model success/failure paths
3. create-action        # Wire validation into the endpoint
4. handle-errors        # Map validation failures to HTTP responses
5. write-action-spec    # Test validation logic in isolation
```

### Pattern 5: Slice Extraction

When modularizing a growing application.

```text
1. create-new-slice     # Generate the slice
2. define-routes        # Mount routes under a prefix
3. configure-slice      # Add slice-specific settings/providers
4. inject-dependencies  # Setup cross-slice imports/exports
5. write-request-spec   # Smoke test the slice
```

---

## Skill Chaining Reference

| Skill | Natural Next Skills | Never Chain With |
|---|---|---|
| `write-migration` | `define-relation`, `define-entity`, `add-table-column` | `create-action` (too far apart) |
| `define-relation` | `create-repository`, `define-entity`, `write-rom-spec` | `create-view` (skip repository layer) |
| `create-repository` | `create-action`, `handle-result-pattern`, `write-rom-spec` | `validate-params` (wrong layer) |
| `define-entity` | `define-relation`, `create-repository`, `create-view` | `handle-errors` (wrong layer) |
| `create-action` | `validate-params`, `handle-errors`, `create-view`, `write-request-spec` | `write-migration` (wrong direction) |
| `validate-params` | `handle-errors`, `handle-result-pattern` | `define-relation` (wrong layer) |
| `handle-errors` | `create-action`, `write-request-spec` | `define-entity` (wrong layer) |
| `inject-dependencies` | `create-action`, `create-repository`, `create-view` | `write-migration` (wrong layer) |
| `register-provider` | `inject-dependencies`, `manage-settings` | `create-view` (wrong layer) |
| `create-view` | `write-request-spec` | `write-migration` (wrong layer) |
| `plan-tests` | `write-request-spec`, `write-action-spec`, `write-rom-spec` | `create-action` (plan first, then test) |
| `review-code` | `refactor-code` | `write-migration` (review after code exists) |

---

## Personas vs. Ad-Hoc Chaining

### Use a Workflow when...

- The task is common and well-defined (e.g., "add a CRUD resource")
- You want a checklist of steps
- You're learning Hanami and want guardrails
- The sequence is always the same

**Examples**: `build-crud-resource`, `tdd-loop`, `add-table-column`

### Use Ad-Hoc Chaining when...

- The task is unique or doesn't fit a workflow
- You're adding one feature to an existing resource
- You're debugging or refactoring
- You need to skip steps (e.g., adding an endpoint to existing data)

**Example**: Adding a search endpoint to an existing `Users` resource:
```text
create-action → validate-params → inject-dependencies → write-request-spec
```
(No need for `define-entity`, `define-relation`, etc. — they already exist.)

---

## MCP Server Usage Patterns

### Discover First

```bash
# List all available skills
list_skills

# Search for migration-related skills
list_skills --query migration
```

### Load on Demand

```bash
# Load the skill you need right now
use_skill write-migration

# Load a workflow
use_skill build-crud-resource
```

### Chain via Prompts

When working with an AI agent, reference skills explicitly:

```text
"I need to add a users table. @write-migration then @define-relation."

"Build a full CRUD resource for posts. @build-crud-resource"

"This action is getting complex. @validate-params then @handle-errors."
```

---

## Anti-Patterns

### Anti-Pattern 1: Skipping the Data Layer

```text
❌ create-action → write-request-spec
     (No entity, no repository — testing raw hashes)
```

```text
✅ define-entity → define-relation → create-repository → create-action → write-request-spec
```

### Anti-Pattern 2: Testing After Everything

```text
❌ Implement all code → Write tests → Hope they pass
```

```text
✅ plan-tests → write-request-spec (failing) → implement → verify pass
```

### Anti-Pattern 3: Over-Skilling

```text
❌ write-migration → define-relation → define-entity → create-repository
   → validate-params → handle-errors → handle-result-pattern → inject-dependencies
   → create-action → create-view → write-request-spec → review-code
   (for a simple index endpoint that lists users)
```

```text
✅ create-action → inject-dependencies → write-request-spec
   (for a simple index endpoint with existing data layer)
```

### Anti-Pattern 4: Wrong Layer Jumping

```text
❌ write-migration → create-action
     (Skipping relation, entity, and repository)
```

```text
✅ write-migration → define-relation → define-entity → create-repository → create-action
```

---

## Practical Examples

### Example 1: Add a Blog Post Resource

**User request**: "Add a blog post resource with title, body, and published_at."

```text
@build-crud-resource
  1. @define-entity        → Post entity with title, body, published_at
  2. @write-migration      → create_table(:posts)
  3. @define-relation     → schema :posts, infer: true
  4. @create-repository   → post_repo with all, by_id, create, update, delete
  5. @create-action       → Posts::Index, Show, Create, Update, Destroy
  6. @validate-params     → Params DSL for Create/Update
  7. @handle-errors        → 404 for missing, 422 for invalid
  8. @create-view          → Index and Show views
  9. @write-request-spec   → Test all 5 endpoints
  10. @review-code         → Check for violations
```

### Example 2: Add a Search Endpoint to Existing Users

**User request**: "Add a search endpoint that filters users by email."

```text
  1. @create-action       → Users::Search
  2. @validate-params     → require :q param
  3. @inject-dependencies → inject user_repo
  4. @create-repository   → add search_by_email to user_repo (if missing)
  5. @handle-errors        → 400 if :q missing
  6. @write-request-spec   → Test search endpoint
```

### Example 3: Add Authentication

**User request**: "Add login/logout to the app."

```text
@setup-authentication
  1. @register-provider   → Register auth provider in container
  2. @inject-dependencies → Inject auth service into actions
  3. @create-action       → Sessions::Create (login), Sessions::Destroy (logout)
  4. @validate-params     → Validate email/password
  5. @handle-errors        → 401 for invalid credentials
  6. @write-request-spec   → Test login/logout flow
```

### Example 4: Background Job for Emails

**User request**: "Send welcome emails asynchronously."

```text
@add-background-jobs
  1. @register-provider   → Register Sidekiq/GoodJob provider
  2. @inject-dependencies → Inject job adapter into actions
  3. @create-action       → Users::Create enqueues welcome email
  4. @write-action-spec   → Test that job is enqueued
```

---

## Quick Reference Card

| If you need to... | Start with... |
|---|---|
| Add a new database table | `write-migration` |
| Add a new HTTP endpoint | `create-action` |
| Validate user input | `validate-params` |
| Handle errors gracefully | `handle-errors` |
| Add a new screen/page | `create-view` |
| Test a full request | `write-request-spec` |
| Test Action logic alone | `write-action-spec` |
| Test database queries | `write-rom-spec` |
| Add DI to a class | `inject-dependencies` |
| Register a service | `register-provider` |
| Review code quality | `review-code` |
| Clean up code | `refactor-code` |
| Plan which tests to write | `plan-tests` |
| Add a full CRUD resource | `build-crud-resource` |
| Add a new slice | `create-new-slice` |
| Follow TDD strictly | `tdd-loop` |

---

## Tips for AI Agents

1. **Always plan first**: Use `plan-tests` before writing any code.
2. **Load skills on demand**: Don't preload all skills — use the MCP server to load them as needed.
3. **Follow handoff conditions**: Each skill lists a "handoff condition." Don't proceed until it's met.
4. **Respect the TDD gate**: Write a failing test before implementation. No exceptions.
5. **Chain, don't nest**: Skills are sequential, not hierarchical. Finish one skill before starting the next.
6. **Review before refactoring**: Always run `review-code` before `refactor-code`.
7. **Test at the right level**: Use request specs for user-facing behavior, unit specs for isolated logic.
