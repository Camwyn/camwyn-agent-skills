#!/usr/bin/env bash
set -e

TARGET_DIR="${1:-$HOME/.agents/skills}"

echo "========================================"
echo "  Camwyn Agent Skills Installer"
echo "========================================"
echo "Target Directory: $TARGET_DIR"
echo ""

mkdir -p "$TARGET_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find all directories containing SKILL.md
find "$SCRIPT_DIR/skills" -name "SKILL.md" | while read -r skill_file; do
  skill_folder=$(dirname "$skill_file")
  skill_name=$(basename "$skill_folder")
  echo "  [LINK] $skill_name -> $skill_folder"
  ln -sfn "$skill_folder" "$TARGET_DIR/$skill_name"
done

CONFIG_TARGET="$HOME/.agents/obsidian-config.json"
CONFIG_EXAMPLE="$SCRIPT_DIR/skills/obsidian-rag/obsidian-config.json.example"
if [ ! -f "$CONFIG_TARGET" ] && [ -f "$CONFIG_EXAMPLE" ]; then
  echo "  [CONFIG] Creating default config at $CONFIG_TARGET"
  cp "$CONFIG_EXAMPLE" "$CONFIG_TARGET"
fi

echo ""
echo "All skills installed and active!"
