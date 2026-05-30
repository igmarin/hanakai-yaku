#!/usr/bin/env bash
set -euo pipefail

# validate-plugins.sh — checks frontmatter consistency and plugin.json ↔ disk sync

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
errors=0

info()  { echo "  [OK] $*"; }
error() { echo "  [FAIL] $*"; errors=$((errors + 1)); }

echo "=== plugin.json inventory check ==="

# Every skill discovered from plugin.json must exist on disk
while IFS= read -r path; do
  skill_md="$ROOT/$path/SKILL.md"
  if [ -f "$skill_md" ]; then
    info "plugin.json → disk: $path"
  else
    error "plugin.json references missing file: $path"
  fi
done < <(ruby -rjson -e '
  data = JSON.parse(File.read(ARGV[0]))
  skills = data.fetch("skills", "")
  if skills.is_a?(String)
    dir = File.join(ARGV[1], skills)
    Dir.glob("**/SKILL.md", base: dir).each { |p| puts "#{skills}#{File.dirname(p)}" }
  elsif skills.is_a?(Array)
    skills.each { |p| puts p }
  end
' "$ROOT/.tessl-plugin/plugin.json" "$ROOT")

echo ""
echo "=== disk → plugin.json check ==="

# Every SKILL.md on disk should be discoverable via plugin.json
expected_skill_dirs=$(ruby -rjson -e '
  data = JSON.parse(File.read(ARGV[0]))
  skills = data.fetch("skills", "./skills/")
  if skills.is_a?(String)
    dir = skills.sub(%r{^\./}, "")
    Dir.glob("*/SKILL.md", base: File.join(ARGV[1], dir)).each { |p| puts "#{dir}#{File.dirname(p)}" }
    Dir.glob("*/*/SKILL.md", base: File.join(ARGV[1], dir)).each { |p| puts "#{dir}#{File.dirname(p)}" }
  elsif skills.is_a?(Array)
    skills.each { |s| puts s.sub(%r{^\./}, "") }
  end
' "$ROOT/.tessl-plugin/plugin.json" "$ROOT" | sort)
while IFS= read -r file; do
  skill_dir="$(dirname "${file#$ROOT/}")"
  if printf '%s\n' "$expected_skill_dirs" | grep -Fxq "$skill_dir"; then
    info "disk → plugin.json: $skill_dir"
  else
    error "disk has SKILL.md not in plugin.json: $skill_dir"
  fi
done < <(find "$ROOT/skills" -name 'SKILL.md' | sort)

echo ""
echo "=== frontmatter name check ==="

while IFS= read -r file; do
  dir_name="$(basename "$(dirname "$file")")"
  fm_name="$(ruby -ryaml -e '
    content = File.read(ARGV[0])
    yaml_end = content.index("---", 3) || content.length
    fm = YAML.safe_load(content[4..yaml_end-1])
    puts fm["name"]
  ' "$file")"
  if [ "$fm_name" = "$dir_name" ]; then
    info "$file: name '$fm_name' matches directory '$dir_name'"
  else
    error "$file: name '$fm_name' does NOT match directory '$dir_name'"
  fi
done < <(find "$ROOT/skills" -name 'SKILL.md' | sort)

echo ""
if [ "$errors" -eq 0 ]; then
  echo "All checks passed."
else
  echo "$errors error(s) found."
  exit 1
fi
