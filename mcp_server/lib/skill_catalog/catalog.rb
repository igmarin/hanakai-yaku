# frozen_string_literal: true

require_relative "catalog_entry"
require_relative "skill_content"
require_relative "skill_metadata"
require_relative "parser"
require_relative "scanner"
require_relative "validator"
require_relative "errors"

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
  # @return [Array<::CatalogEntry>]
  def list
    @catalog.values.map do |metadata|
      ::CatalogEntry.new(
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
  # @return [::SkillContent]
  # @raise [::SkillNotFoundError] if the name is not in the catalog
  def fetch(name)
    metadata = @catalog[name]
    raise ::SkillNotFoundError.new(name, @catalog.keys.sort) unless metadata

    content = File.read(metadata.file_path)
    ::SkillContent.new(
      name: metadata.name,
      content: content,
      metadata: metadata
    )
  end

  # Yields each metadata entry in the catalog.
  #
  # @yieldparam metadata [::SkillMetadata] skill metadata
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
  # @return [Hash<String, ::SkillMetadata>] Catalog indexed by skill name
  def build_catalog
    catalog = {}

    ::Scanner.scan_directory(skills_root, "skills").each do |metadata|
      add_to_catalog(catalog, metadata)
    end

    ::Scanner.scan_directory(workflows_root, "workflows").each do |metadata|
      add_to_catalog(catalog, metadata)
    end

    catalog
  end

  # Adds a metadata entry to the catalog, checking for duplicates.
  #
  # @param catalog [Hash<String, ::SkillMetadata>] The catalog to modify
  # @param metadata [::SkillMetadata] The metadata to add
  # @raise [::DuplicateSkillNameError] if the skill name already exists
  def add_to_catalog(catalog, metadata)
    if catalog.key?(metadata.name)
      existing = catalog[metadata.name]
      raise ::DuplicateSkillNameError.new(metadata.name, existing.file_path, metadata.file_path)
    end

    catalog[metadata.name] = metadata
  end
end
