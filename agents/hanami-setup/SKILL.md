---
name: hanami-setup
license: MIT
description: >
  Orchestrates Hanami project onboarding: loads application context, configures
  providers, implements dependency injection patterns, and verifies the setup.
  Use when setting up a new Hanami project, onboarding a developer, or
  configuring services and DI.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when setting up a new Hanami project, onboarding, or configuring providers and DI"
  phases: "Phase 1: Context Loading, Phase 2: Provider Configuration, Phase 3: DI Implementation, Phase 4: Verification"
  hard_gates: "Context Loaded, Providers Verified"
  dependencies: "load-context, configure-providers, implement-di"
  keywords: hanami, setup, onboarding, providers, DI, dependency injection, configuration, boot
---
# Hanami Setup Agent

Orchestrates project onboarding: from context discovery through provider configuration to DI implementation. Chains three skills through four phases with verification gates.

## When to Use

- Setting up a new Hanami project and need providers, settings, and DI configured
- Onboarding a developer — "show me how this app is structured"
- Adding new services that need providers and DI
- Verifying an existing setup is correct

## Anti-Patterns

- Do not skip context loading — every phase depends on knowing the app structure
- Do not configure providers without understanding existing ones
- Do not implement DI without registered providers
- Do not skip verification — an unverified setup leads to boot failures

## Agent Phases

### Phase 1: Context Loading

1. Activate **context/load-context**: Discover all slices, providers, settings, routes, and patterns.
2. Produce the full context map: slices, providers, settings, route summary, DI conventions.

**HARD GATE — Context Loaded:**
```text
Context MUST be fully loaded before any configuration work.
DO NOT proceed without a complete slice map, provider inventory, and settings summary.
If the app cannot load context (broken boot), fix that first.
```

---

### Phase 2: Provider Configuration

1. Activate **providers/configure-providers**: Review existing providers and configure new ones.
2. For new providers: define settings, create provider file, register component.
3. For existing providers: verify they match conventions and settings are properly typed.

**Quality Check:**
- Every external service has a provider.
- All environment values go through settings (no `ENV.fetch` in providers).
- Provider registration keys are descriptive.

---

### Phase 3: DI Implementation

1. Activate **providers/implement-di**: Implement dependency injection in consumers.
2. Verify every action and operation that needs injected dependencies uses `include Deps[...]`.
3. Confirm test patterns support constructor injection of test doubles.

**Quality Check:**
- No direct container calls exist outside of providers.
- Deps keys match provider registration keys exactly.
- At least one action and one operation are verified with DI.

---

### Phase 4: Verification

1. Boot the app and verify all providers start without errors.
2. Run the test suite to confirm injected dependencies resolve correctly.
3. Verify the slice map matches expectations.
4. Check that settings are properly typed and environment values are set.

**HARD GATE — Providers Verified:**
```text
All providers MUST boot without errors.
The test suite MUST pass with DI configured.
DO NOT consider setup complete if any provider fails to start.
```

---

## Error Recovery

| Scenario | Recovery |
|----------|----------|
| App fails to boot (missing settings) | Define the missing setting in `config/settings.rb` with proper type constructor. Re-run boot. |
| Provider fails to start (connection refused) | Verify the external service is running. If it's optional, wrap startup in a rescue block. |
| Deps key not found | Verify the provider's registration key matches the Deps key exactly. Check for typos. |
| Test fails after DI (nil dependency) | Ensure the test passes the dependency through the constructor. Check the key name. |
| ROM auto_registration missing a slice | Verify the slice path is correct. Check that relations follow the expected directory structure. |

## Output Style / Report

```markdown
## Hanami Setup Complete

### Context
- Slices: [N] discovered — [list]
- Providers: [N] configured — [list]
- Settings: [N] defined — [summary]

### Providers
- [provider] — registered as "[key]" — [status: new/verified]

### Dependency Injection
- Actions using DI: [N]
- Operations using DI: [N]
- Test patterns verified: Yes / No

### Verification
- App boots: Yes / No
- Tests pass: [N] passed, [N] failed
- Warnings: [any issues to address]
```
