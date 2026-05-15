# frozen_string_literal: true

# Lightweight catalog entry for listing skills without loading full content.
#
# @!attribute [r] name [String] The canonical skill name from frontmatter
# @!attribute [r] description [String] Brief description of the skill
# @!attribute [r] category [String] Either "skills" or "workflows"
# @!attribute [r] ecosystem_sources [Array<String>] List of external dependencies
CatalogEntry = Data.define(:name, :description, :category, :ecosystem_sources)
