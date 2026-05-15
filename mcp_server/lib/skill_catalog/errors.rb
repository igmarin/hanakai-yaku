# frozen_string_literal: true

# Custom error classes for SkillCatalog
# Raised when a requested skill name is not present in the catalog.
class SkillNotFoundError < StandardError
  attr_reader :requested_name, :available_names

  # @param requested_name [String] the skill name that was not found
  # @param available_names [Array<String>] all known skill names in the catalog
  def initialize(requested_name, available_names)
    @requested_name = requested_name
    @available_names = available_names
    super("Skill '#{requested_name}' not found. Available: #{available_names.join(', ')}")
  end
end

# Raised when two SKILL.md files declare the same frontmatter name.
class DuplicateSkillNameError < StandardError
  # @param name [String] the duplicated skill name
  # @param path1 [String] first file path where the name was found
  # @param path2 [String] second file path where the name was found
  def initialize(name, path1, path2)
    super("Duplicate skill name '#{name}' found in:\n  #{path1}\n  #{path2}")
  end
end

# Raised when a SKILL.md file is missing a required frontmatter field.
class InvalidSkillError < StandardError
  # @param field [String] the missing or invalid frontmatter key
  # @param file_path [String] path to the offending SKILL.md
  def initialize(field, file_path)
    super("Invalid skill: missing required frontmatter field '#{field}' in #{file_path}")
  end
end
