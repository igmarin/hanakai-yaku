# frozen_string_literal: true

# Parsed frontmatter metadata from a SKILL.md file.
#
# @!attribute [r] name [String] The canonical skill name (required)
# @!attribute [r] version [String] Skill version (defaults to "1.0.0")
# @!attribute [r] license [String] License identifier (defaults to "MIT")
# @!attribute [r] description [String] Brief description (required)
# @!attribute [r] ecosystem_sources [Array<String>] External dependencies (required)
# @!attribute [r] tags [Array<String>] Keyword tags for categorization
# @!attribute [r] file_path [String] Absolute path to the SKILL.md file
# @!attribute [r] category [String] Either "skills" or "agents"
# @!attribute [r] is_workflow [Boolean] True if this is a workflow, false for atomic skill
SkillMetadata = Data.define(:name, :version, :license, :description, :ecosystem_sources, :tags, :file_path, :category, :is_workflow)
