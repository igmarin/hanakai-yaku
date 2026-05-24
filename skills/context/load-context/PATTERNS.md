# Sampling Codebase Patterns in Hanami 2.x

This document guides developers and agents on how to identify, inspect, and match existing design patterns within a Hanami codebase.

---

## What to Sample

To maintain codebase architectural consistency, analyze files from three main layers:

### 1. Action Patterns
When sampling files in `app/actions/` or `slices/*/actions/`, identify:
- **Base class:** What action class do they inherit from (e.g. `MyApp::Action`, `Admin::Action`)?
- **DI usage:** How are dependencies declared (e.g. `include Deps["repos.user_repo"]`)?
- **Response handling:** Are they rendering views, returning JSON strings directly, or using `halt`?
- **Params validation:** Is there an inline `params` schema block or do they delegate validation?

### 2. Operation Patterns
When sampling files in `app/operations/` or `slices/*/operations/`, identify:
- **Monadic Results:** Do they return `Success`/`Failure` using `dry-monads`?
- **Do Notation:** Is `include Dry::Monads::Do.for(:call)` used to chain commands?
- **Interface:** Is `#call` the universal execution entry point?

### 3. Repository/Database Patterns
When sampling files in `app/repos/` or `slices/*/repos/`, identify:
- **Inheritance:** Do they inherit from a central base repository (e.g. `Hanami::DB::Repo[:users]`)?
- **Namespace mapping:** Is `struct_namespace` configured to map database results to domain entities?
- **Scope usage:** Do they call relation scopes or execute custom queries inside repo methods?
