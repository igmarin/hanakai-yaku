# Workflow Guide

This document provides narrative descriptions of each workflow in the `hanakai-yaku` repository.

## TDD Workflow

The core development loop for all Hanami 2.x features.

1. **Plan** — Decide which test type to use (request spec, action unit spec, ROM spec)
2. **Write** — Write a failing test that describes the desired behavior
3. **Verify** — Run the test and confirm it fails for the right reason
4. **Implement** — Write the minimal code to make the test pass
5. **Review** — Run review-code skill to check for violations

**When to use**: Every code-producing task.

## CRUD Resource Workflow

Implement a full Create, Read, Update, Delete resource.

1. **Entity** — Define the data structure
2. **Relation** — Map the database table
3. **Repository** — Add persistence methods
4. **Actions** — Create HTTP endpoints
5. **Views** — Add presentation layer (for HTML)
6. **Tests** — Write request specs
7. **Review** — Code review

**When to use**: Adding a new model/resource to the application.

## API Slice Workflow

Create a self-contained API module.

1. **Slice** — Generate and register the slice
2. **Actions** — Create JSON API endpoints
3. **Routes** — Mount at `/api` prefix
4. **Tests** — Write request specs for all endpoints
5. **Review** — Code review

**When to use**: Building a JSON API that should be modular.

## Authentication Workflow

Add authentication to Hanami 2.x.

1. **DI Setup** — Create auth service and register in container
2. **Provider** — Configure auth provider
3. **Actions** — Create login/logout endpoints
4. **Protection** — Add auth checks to protected endpoints

**When to use**: Adding user authentication.

## Add Table Column Workflow

Safely add a column to an existing table.

1. **Migration** — Generate and write migration
2. **Apply** — Run migration
3. **Relation** — Update schema if explicit
4. **Entity** — Add attribute
5. **Repository** — Update methods
6. **Tests** — Update specs

**When to use**: Schema changes that require cascading updates.

## New Slice Workflow

Create a new bounded context.

1. **Generate** — `hanami generate slice <name>`
2. **Routes** — Define slice routes
3. **Configure** — Add settings/providers
4. **DI** — Setup imports/exports
5. **Test** — Smoke tests

**When to use**: Modularizing the application.

## Validation Contract Workflow

Implement complex validation with dry-validation.

1. **Contract** — Define validation rules
2. **Register** — Add to DI container
3. **Action** — Use in Action
4. **Handle** — Map failures to HTTP responses
5. **Test** — Test contract in isolation

**When to use**: Complex input validation beyond simple Params DSL.

## Background Jobs Workflow

Integrate async job processing.

1. **Adapter** — Register Sidekiq/GoodJob provider
2. **DI** — Inject into Actions
3. **Enqueue** — Push jobs from Actions
4. **Test** — Test job classes

**When to use**: Deferring work (emails, exports, notifications).
