# Installing Hanami Skills for Codex

## Manual Installation

1. Clone this repository:

   ```bash
   git clone https://gitlab.com/igmarin/hanami-skills.git
   ```

2. Configure your Codex agent to load skills from the `skills/` directory.

## Usage

Reference skills by their canonical `name` from frontmatter. Invoke them with the `@skill-name` syntax:

```text
@write-migration — How do I add a column to an existing table?
@tdd-loop — I need to implement a new user registration feature
```
