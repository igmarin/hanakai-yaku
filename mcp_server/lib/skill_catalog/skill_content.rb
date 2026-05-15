# frozen_string_literal: true

# Full skill content including the SKILL.md file content and metadata.
#
# @!attribute [r] name [String] The canonical skill name from frontmatter
# @!attribute [r] content [String] The full SKILL.md file content
# @!attribute [r] metadata [SkillMetadata] Parsed frontmatter metadata
SkillContent = Data.define(:name, :content, :metadata)
