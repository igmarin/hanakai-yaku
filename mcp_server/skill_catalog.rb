# frozen_string_literal: true

require "yaml"

# Scans skills/ and workflows/ directories, parses SKILL.md frontmatter,
# and exposes a searchable catalog of available skills.
#
# This class provides a unified interface for discovering and loading Hanami skills
# and workflows. It scans the specified directories for SKILL.md files, parses their
# YAML frontmatter, and builds an in-memory catalog indexed by skill name.
#
# The catalog supports both atomic skills (in skills/) and workflows (in workflows/),
# distinguishing them via the category field. It validates frontmatter to ensure
# required fields are present and detects duplicate skill names.
#
# @example Basic usage
#   catalog = SkillCatalog.new(skills_root: "skills", workflows_root: "workflows")
#   catalog.list # => [#<CatalogEntry name="write-migration" ...>, ...]
#   skill = catalog.fetch("write-migration")
#   skill.content # => Full SKILL.md content
#
# @see CatalogEntry Lightweight entry for listing
# @see SkillContent Full skill content with metadata
# @see SkillMetadata Parsed frontmatter data
class SkillCatalog
  # Lightweight catalog entry for listing skills without loading full content.
  #
  # @!attribute [r] name [String] The canonical skill name from frontmatter
  # @!attribute [r] description [String] Brief description of the skill
  # @!attribute [r] category [String] Either "skills" or "workflows"
  # @!attribute [r] ecosystem_sources [Array<String>] List of external dependencies
  CatalogEntry = Data.define(:name, :description, :category, :ecosystem_sources)

  # Full skill content including the SKILL.md file content and metadata.
  #
  # @!attribute [r] name [String] The canonical skill name from frontmatter
  # @!attribute [r] content [String] The full SKILL.md file content
  # @!attribute [r] metadata [SkillMetadata] Parsed frontmatter metadata
  SkillContent = Data.define(:name, :content, :metadata)

  # Parsed frontmatter metadata from a SKILL.md file.
  #
  # @!attribute [r] name [String] The canonical skill name (required)
  # @!attribute [r] version [String] Skill version (defaults to "1.0.0")
  # @!attribute [r] license [String] License identifier (defaults to "MIT")
  # @!attribute [r] description [String] Brief description (required)
  # @!attribute [r] ecosystem_sources [Array<String>] External dependencies (required)
  # @!attribute [r] tags [Array<String>] Keyword tags for categorization
  # @!attribute [r] file_path [String] Absolute path to the SKILL.md file
  # @!attribute [r] category [String] Either "skills" or "workflows"
  # @!attribute [r] is_workflow [Boolean] True if this is a workflow, false for atomic skill
  SkillMetadata = Data.define(:name, :version, :license, :description, :ecosystem_sources, :tags, :file_path, :category, :is_workflow)

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

  # @return [String]
  attr_reader :skills_root
  # @return [String]
  attr_reader :workflows_root

  # @param skills_root [String] directory containing atomic skills
  # @param workflows_root [String] directory containing workflows
  def initialize(skills_root:, workflows_root:)
    @skills_root = skills_root
    @workflows_root = workflows_root
    @catalog = build_catalog
  end

  # Returns all discovered skills and workflows as lightweight catalog entries.
  #
  # @return [Array<CatalogEntry>]
  def list
    @catalog.values.map do |metadata|
      CatalogEntry.new(
        name: metadata.name,
        description: metadata.description,
        category: metadata.category,
        ecosystem_sources: metadata.ecosystem_sources
      )
    end
  end

  # Loads the full content of a skill by its canonical name.
  #
  # @param name [String] canonical skill name from frontmatter
  # @return [SkillContent]
  # @raise [SkillNotFoundError] if the name is not in the catalog
  def fetch(name)
    metadata = @catalog[name]
    raise SkillNotFoundError.new(name, @catalog.keys.sort) unless metadata

    content = File.read(metadata.file_path)
    SkillContent.new(
      name: metadata.name,
      content: content,
      metadata: metadata
    )
  end

  # Yields each metadata entry in the catalog.
  #
  # @yieldparam metadata [SkillMetadata] skill metadata
  # @return [Enumerator] if no block is given
  def each
    return enum_for(:each) unless block_given?

    @catalog.each_value do |metadata|
      yield metadata
    end
  end

  private

  # Builds the in-memory catalog by scanning both skills and workflows directories.
  #
  # @return [Hash<String, SkillMetadata>] Catalog indexed by skill name
  def build_catalog
    catalog = {}

    scan_directory(skills_root, "skills").each do |metadata|
      add_to_catalog(catalog, metadata)
    end

    scan_directory(workflows_root, "workflows").each do |metadata|
      add_to_catalog(catalog, metadata)
    end

    catalog
  end

  # Scans a directory recursively for SKILL.md files and parses their metadata.
  #
  # @param root [String] Root directory to scan
  # @param category [String] Category label ("skills" or "workflows")
  # @return [Array<SkillMetadata>] Array of parsed metadata entries
  def scan_directory(root, category)
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
  # @return [SkillMetadata, nil] Parsed metadata, or nil if parsing fails
  def parse_skill_file(file_path, category)
    content = File.read(file_path)
    frontmatter = extract_frontmatter(content)
    return nil unless frontmatter

    metadata = SkillMetadata.new(
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

    validate_metadata!(metadata, file_path)
    metadata
  rescue Psych::SyntaxError => e
    warn "Warning: malformed YAML in #{file_path}: #{e.message}"
    nil
  rescue Errno::ENOENT, Errno::EACCES, Errno::EPERM => e
    warn "Warning: cannot read #{file_path}: #{e.message}"
    nil
  end

  # Extracts YAML frontmatter from a SKILL.md file content.
  #
  # @param content [String] Full file content
  # @return [Hash, nil] Parsed YAML frontmatter, or nil if not present/invalid
  def extract_frontmatter(content)
    return nil unless content.start_with?("---")

    _, frontmatter, _ = content.split("---", 3)
    return nil if frontmatter.nil? || frontmatter.strip.empty?

    YAML.safe_load(frontmatter, permitted_classes: [], permitted_symbols: [], aliases: true)
  rescue Psych::SyntaxError => e
    warn "Warning: malformed YAML: #{e.message}"
    nil
  end

  # Validates that required frontmatter fields are present and correctly typed.
  #
  # @param metadata [SkillMetadata] The metadata to validate
  # @param file_path [String] Path to the SKILL.md file (for error messages)
  # @raise [InvalidSkillError] if validation fails
  def validate_metadata!(metadata, file_path)
    field_values = {
      "name" => metadata.name,
      "license" => metadata.license,
      "description" => metadata.description,
      "ecosystem_sources" => metadata.ecosystem_sources
    }

    field_values.each do |field, value|
      if value.nil? || (value.respond_to?(:empty?) && value.empty?)
        raise InvalidSkillError.new(field, file_path)
      end
    end

    unless metadata.ecosystem_sources.is_a?(Array)
      raise InvalidSkillError.new("ecosystem_sources must be an Array", file_path)
    end

    unless metadata.tags.is_a?(Array)
      raise InvalidSkillError.new("tags must be an Array", file_path)
    end
  end

  # Adds a metadata entry to the catalog, checking for duplicates.
  #
  # @param catalog [Hash<String, SkillMetadata>] The catalog to modify
  # @param metadata [SkillMetadata] The metadata to add
  # @raise [DuplicateSkillNameError] if the skill name already exists
  def add_to_catalog(catalog, metadata)
    if catalog.key?(metadata.name)
      existing = catalog[metadata.name]
      raise DuplicateSkillNameError.new(metadata.name, existing.file_path, metadata.file_path)
    end

    catalog[metadata.name] = metadata
  end
end
