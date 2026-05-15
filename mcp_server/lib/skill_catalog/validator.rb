# frozen_string_literal: true

require_relative "errors"
require_relative "skill_metadata"

# Validates skill metadata
module Validator
  # Validates that required frontmatter fields are present and correctly typed.
  #
  # @param metadata [::SkillMetadata] The metadata to validate
  # @param file_path [String] Path to the SKILL.md file (for error messages)
  # @raise [::InvalidSkillError] if validation fails
  def self.validate_metadata!(metadata, file_path)
    field_values = {
      "name" => metadata.name,
      "license" => metadata.license,
      "description" => metadata.description,
      "ecosystem_sources" => metadata.ecosystem_sources
    }

    field_values.each do |field, value|
      if value.nil? || (value.respond_to?(:empty?) && value.empty?)
        raise ::InvalidSkillError.new(field, file_path)
      end
    end

    unless metadata.ecosystem_sources.is_a?(Array)
      raise ::InvalidSkillError.new("ecosystem_sources must be an Array", file_path)
    end

    unless metadata.tags.is_a?(Array)
      raise ::InvalidSkillError.new("tags must be an Array", file_path)
    end
  end
end
