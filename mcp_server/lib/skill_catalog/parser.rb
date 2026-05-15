# frozen_string_literal: true

require "yaml"

# Parses YAML frontmatter from SKILL.md files
module Parser
  # Extracts YAML frontmatter from a SKILL.md file content.
  #
  # @param content [String] Full file content
  # @return [Hash, nil] Parsed YAML frontmatter, or nil if not present/invalid
  def self.extract_frontmatter(content)
    return nil unless content.start_with?("---")

    _, frontmatter, _ = content.split("---", 3)
    return nil if frontmatter.nil? || frontmatter.strip.empty?

    YAML.safe_load(frontmatter, permitted_classes: [], permitted_symbols: [], aliases: true)
  rescue Psych::SyntaxError => e
    warn "Warning: malformed YAML: #{e.message}"
    nil
  end
end
