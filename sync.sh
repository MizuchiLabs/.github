#!/usr/bin/env bash
# Copies the shared templates into the sibling repo checkouts next to this one.
# Usage: ./sync.sh [--check]
# --check only reports drift and exits 1 if anything differs.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(dirname "$here")"
templates="$here/templates"
check=false
[ "${1:-}" = "--check" ] && check=true
drift=0

for repo in "$root"/*/; do
  repo="${repo%/}"
  [ "$repo" = "$here" ] && continue
  [ -d "$repo/.git" ] || continue

  changed=()
  sync() {
    local src="$templates/$1" dst="$repo/$2"
    cmp -s "$src" "$dst" && return
    changed+=("$2")
    $check && return
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
  }

  # Only repos that already opted into renovate.
  [ -f "$repo/.github/renovate.json" ] && sync renovate.json .github/renovate.json

  if [ -f "$repo/go.mod" ]; then
    sync go/.golangci.yml .golangci.yml
    # Repos with their own release flow (kagi) keep their own cliff.toml.
    if grep -qs 'go-release.yaml' "$repo/.github/workflows/release.yaml"; then
      sync go/cliff.toml cliff.toml
    fi
  fi

  if [ ${#changed[@]} -gt 0 ]; then
    drift=1
    echo "$(basename "$repo"): ${changed[*]}"
  fi
done

if $check && [ $drift -eq 1 ]; then
  exit 1
fi
