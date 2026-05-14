# frozen_string_literal: true

require "yaml"

class SkillCatalog
  CatalogEntry = Data.define(:name, :description, :category, :ecosystem_sources)
  SkillContent = Data.define(:name, :content, :metadata)
  SkillMetadata = Data.define(:name, :version, :license, :description, :ecosystem_sources, :tags, :file_path, :category, :is_workflow)

  class SkillNotFoundError < StandardError
    attr_reader :requested_name, :available_names

    def initialize(requested_name, available_names)
      @requested_name = requested_name
      @available_names = available_names
      super("Skill '#{requested_name}' not found. Available: #{available_names.join(', ')}")
    end
  end

  class DuplicateSkillNameError < StandardError
    def initialize(name, path1, path2)
      super("Duplicate skill name '#{name}' found in:\n  #{path1}\n  #{path2}")
    end
  end

  class InvalidSkillError < StandardError
    def initialize(field, file_path)
      super("Invalid skill: missing required frontmatter field '#{field}' in #{file_path}")
    end
  end

  attr_reader :skills_root, :workflows_root

  def initialize(skills_root:, workflows_root:)
    @skills_root = skills_root
    @workflows_root = workflows_root
    @catalog = build_catalog
  end

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

  def each
    return enum_for(:each) unless block_given?

    @catalog.each do |name, metadata|
      yield metadata
    end
  end

  private

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

  def scan_directory(root, category)
    return [] unless File.directory?(root)

    metadata_list = []

    Dir.glob(File.join(root, "**", "SKILL.md")).each do |file_path|
      metadata = parse_skill_file(file_path, category)
      metadata_list << metadata if metadata
    end

    metadata_list
  end

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
  end

  def extract_frontmatter(content)
    return nil unless content.start_with?("---")

    _, frontmatter, _ = content.split("---", 3)
    return nil if frontmatter.nil? || frontmatter.strip.empty?

    YAML.safe_load(frontmatter, permitted_classes: [], permitted_symbols: [], aliases: true)
  rescue Psych::SyntaxError
    nil
  end

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
  end

  def add_to_catalog(catalog, metadata)
    if catalog.key?(metadata.name)
      existing = catalog[metadata.name]
      raise DuplicateSkillNameError.new(metadata.name, existing.file_path, metadata.file_path)
    end

    catalog[metadata.name] = metadata
  end
end
