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

for skill in "$SCRIPT_DIR"/skills/*; do
  if [ -d "$skill" ]; then
    skill_name=$(basename "$skill")
    echo "  [LINK] $skill_name -> $skill"
    ln -sfn "$skill" "$TARGET_DIR/$skill_name"
  fi
done

CONFIG_TARGET="$HOME/.agents/obsidian-config.json"
if [ ! -f "$CONFIG_TARGET" ] && [ -f "$SCRIPT_DIR/obsidian-config.json.example" ]; then
  echo "  [CONFIG] Creating default config at $CONFIG_TARGET"
  cp "$SCRIPT_DIR/obsidian-config.json.example" "$CONFIG_TARGET"
fi

echo ""
echo "All skills installed and active!"
echo "Available skills:"
for skill in "$SCRIPT_DIR"/skills/*; do
  if [ -d "$skill" ]; then
    echo "  - /$(basename "$skill")"
  fi
done
