#!/usr/bin/env bash
# Installerar skills i ~/.claude/skills (symlink som standard, --copy för kopia).
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$repo_dir/skills"
dest_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
mode="link"

for arg in "$@"; do
  case "$arg" in
    --copy) mode="copy" ;;
    -h|--help) sed -n '2,3p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "Okänd flagga: $arg" >&2; exit 1 ;;
  esac
done

mkdir -p "$dest_dir"

shopt -s nullglob
for skill in "$src_dir"/*/; do
  name="$(basename "$skill")"
  target="$dest_dir/$name"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "hoppar över $name (finns redan som riktig mapp i $dest_dir)"
    continue
  fi

  rm -rf "$target"
  if [ "$mode" = "link" ]; then
    ln -s "${skill%/}" "$target"
    echo "länkade $name"
  else
    cp -r "${skill%/}" "$target"
    echo "kopierade $name"
  fi
done
