# frozen_string_literal: true

require_relative "errors"
require_relative "skill_metadata"
require_relative "parser"
require_relative "validator"

# Scans directories for SKILL.md files
module Scanner
  # Scans a directory recursively for SKILL.md files and parses their metadata.
  #
  # @param root [String] Root directory to scan
  # @param category [String] Category label ("skills" or "workflows")
  # @return [Array<::SkillMetadata>] Array of parsed metadata entries
  def self.scan_directory(root, category)
    return [] unless File.directory?(root)

    metadata_list = []

    Dir.glob(File.join(root, "**", "SKILL.md")).each do |file_path|
      metadata = parse_skill_file(file_path, category)
      metadata_list << metadata if metadata
    end

    metadata_list
  end

  # Parses a single SKILL.md file and extracts its metadata.
  #
  # @param file_path [String] Path to the SKILL.md file
  # @param category [String] Category label ("skills" or "workflows")
  # @return [::SkillMetadata, nil] Parsed metadata, or nil if parsing fails
  def self.parse_skill_file(file_path, category)
    content = File.read(file_path)
    frontmatter = ::Parser.extract_frontmatter(content)
    return nil unless frontmatter

    metadata = ::SkillMetadata.new(
      name: frontmatter["name"],
      version: frontmatter["version"] || "1.0.0",
      license: frontmatter["license"] || "MIT",
      description: frontmatter["description"] || "",
      ecosystem_sources: frontmatter["ecosystem_sources"] || [],
      tags: frontmatter["tags"] || [],
      file_path: file_path,
      category: category,
      is_workflow: category == "workflows"
    )

    ::Validator.validate_metadata!(metadata, file_path)
    metadata
  rescue Psych::SyntaxError => e
    warn "Warning: malformed YAML in #{file_path}: #{e.message}"
  rescue Errno::ENOENT, Errno::EACCES, Errno::EPERM => e
    warn "Warning: cannot read #{file_path}: #{e.message}"
    nil
  end
end
