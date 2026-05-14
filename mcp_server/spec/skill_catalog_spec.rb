# frozen_string_literal: true

require "rspec"
require "fileutils"
require_relative "../skill_catalog"

RSpec.describe SkillCatalog do
  let(:fixture_dir) { File.expand_path("fixtures", __dir__) }
  let(:catalog) { described_class.new(skills_root: File.join(fixture_dir, "skills"), workflows_root: File.join(fixture_dir, "workflows")) }

  before do
    FileUtils.mkdir_p(File.join(fixture_dir, "skills", "db", "test-skill"))
    FileUtils.mkdir_p(File.join(fixture_dir, "workflows", "test-workflow"))

    File.write(
      File.join(fixture_dir, "skills", "db", "test-skill", "SKILL.md"),
      <<~SKILL
        ---
        name: test-skill
        version: "1.0.0"
        license: MIT
        description: A test skill
        ecosystem_sources:
          - hanami/hanami
        ---

        # Test Skill

        ## Quick Reference

        | Scenario | Approach |
        |---|---|
        | Test | Test |

        ## Core Rules

        1. Rule one
        2. Rule two

        ## Common Mistakes

        | Mistake | Reality |
        |---|---|
        | Mistake | Reality |

        ## Red Flags

        - Flag

        ## Integration

        | Related Skill | When to chain |
        |---|---|
        | other | always |
      SKILL
    )

    File.write(
      File.join(fixture_dir, "workflows", "test-workflow", "SKILL.md"),
      <<~SKILL
        ---
        name: test-workflow
        version: "1.0.0"
        license: MIT
        description: A test workflow
        ecosystem_sources:
          - hanami/hanami
        ---

        # Test Workflow

        ## Quick Reference

        | Scenario | Approach |
        |---|---|
        | Test | Test |

        ## Core Rules

        1. Rule one

        ## Common Mistakes

        | Mistake | Reality |
        |---|---|
        | Mistake | Reality |

        ## Red Flags

        - Flag

        ## Integration

        | Related Skill | When to chain |
        |---|---|
        | test-skill | always |
      SKILL
    )
  end

  after do
    FileUtils.rm_rf(fixture_dir)
  end

  describe "#list" do
    it "returns all skills and workflows" do
      entries = catalog.list
      names = entries.map(&:name)

      expect(names).to include("test-skill", "test-workflow")
      expect(entries.length).to eq(2)
    end

    it "returns correct entry shape" do
      entry = catalog.list.find { |e| e.name == "test-skill" }

      expect(entry).not_to be_nil
      expect(entry.description).to eq("A test skill")
      expect(entry.category).to eq("skills")
      expect(entry.ecosystem_sources).to eq(["hanami/hanami"])
    end
  end

  describe "#fetch" do
    it "returns correct content for a known skill" do
      skill = catalog.fetch("test-skill")

      expect(skill.name).to eq("test-skill")
      expect(skill.content).to include("# Test Skill")
      expect(skill.metadata.name).to eq("test-skill")
    end

    it "raises SkillNotFoundError for unknown skill" do
      expect {
        catalog.fetch("nonexistent")
      }.to raise_error(SkillCatalog::SkillNotFoundError) do |error|
        expect(error.requested_name).to eq("nonexistent")
        expect(error.available_names).to include("test-skill", "test-workflow")
      end
    end
  end

  describe "duplicate names" do
    before do
      FileUtils.mkdir_p(File.join(fixture_dir, "skills", "actions", "test-skill"))
      File.write(
        File.join(fixture_dir, "skills", "actions", "test-skill", "SKILL.md"),
        <<~SKILL
          ---
          name: test-skill
          version: "1.0.0"
          license: MIT
          description: Duplicate test skill
          ecosystem_sources:
            - hanami/hanami
          ---
        SKILL
      )
    end

    it "raises DuplicateSkillNameError" do
      expect {
        described_class.new(skills_root: File.join(fixture_dir, "skills"), workflows_root: File.join(fixture_dir, "workflows"))
      }.to raise_error(SkillCatalog::DuplicateSkillNameError)
    end
  end

  describe "invalid frontmatter" do
    before do
      FileUtils.mkdir_p(File.join(fixture_dir, "skills", "invalid"))
      File.write(
        File.join(fixture_dir, "skills", "invalid", "SKILL.md"),
        <<~SKILL
          ---
          name: invalid-skill
          ---
        SKILL
      )
    end

    it "raises InvalidSkillError for missing required fields" do
      expect {
        described_class.new(skills_root: File.join(fixture_dir, "skills"), workflows_root: File.join(fixture_dir, "workflows"))
      }.to raise_error(SkillCatalog::InvalidSkillError)
    end
  end

  describe "MCP tool responses" do
    it "list returns JSON-serializable array" do
      entries = catalog.list
      expect(entries).to be_an(Array)
      expect(entries.first).to respond_to(:to_h)
    end

    it "fetch returns string content" do
      skill = catalog.fetch("test-skill")
      expect(skill.content).to be_a(String)
      expect(skill.content.length).to be > 0
    end
  end
end
