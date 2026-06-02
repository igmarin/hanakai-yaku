# Calling Skills and Personas

hanakai-yaku skills can be invoked through chat commands or CLI.

## Invocation Methods

| Method | Syntax | Best For |
|--------|--------|----------|
| **Chat Commands** | `@skill-name` or `/skill-name` | Explicitly forcing the agent to follow a specific skill |
| **CLI (`gh skill` / `skills.sh`)** | `gh skill install ...` | Local installation, pinning versions |

> MCP support is planned but not yet implemented.

---

## Using Skills

```text
@load-context            # Discover slices, providers, settings, routes
@configure-providers     # Set up a provider for an external service
@implement-di            # Add dependency injection to an action or operation
```

---

## Using Personas

```text
@hanami-setup            # Full project onboarding workflow
```

---

## Installing Skills

### Via GitHub CLI

```bash
gh skill install igmarin/hanakai-yaku load-context --scope project
gh skill install igmarin/hanakai-yaku
```

### Via skills.sh

```bash
npx skills add igmarin/hanakai-yaku
```

---

## Available Skills and Personas

### Skills (3)

| Name | Category | Description |
|------|----------|-------------|
| `load-context` | Context | Load the Hanami app structure before coding |
| `configure-providers` | Providers | Set up providers, settings, and service registration |
| `implement-di` | Providers | Dependency injection patterns with dry-system |

### Persona (1)

| Name | Phases | Focus |
|------|--------|-------|
| `hanami-setup` | Context → Providers → DI → Verify | Project onboarding |
