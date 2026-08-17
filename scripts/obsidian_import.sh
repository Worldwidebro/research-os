#!/usr/bin/env bash
# Research OS — Obsidian import
# Runs daily. New/changed notes get triaged by the critic agent.
# Hard conflicts require manual resolution.

set -euo pipefail

SRC="/Users/divinejohns/Obsidian/Research/Questions"
DST="/Users/divinejohns/Projects/repos/research-os/research/questions/"
INBOX="/Users/divinejohns/Projects/repos/research-os/00_INBOX/obsidian/"
CONFLICTS_LOG="/Users/divinejohns/Projects/repos/research-os/00_INBOX/conflicts.log"
LOG="/Users/divinejohns/Projects/repos/research-os/00_INBOX/sync.log"

mkdir -p "$INBOX"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

log "=== Obsidian import starting ==="

for f in "$SRC/"*.md; do
  [[ -f "$f" ]] || continue
  filename=$(basename "$f")
  dst_file="$DST/$filename"

  if [[ ! -f "$dst_file" ]]; then
    # New file — promote to questions
    cp "$f" "$dst_file"
    log "NEW: $filename → $dst_file"
    continue
  fi

  if [[ "$dst_file" -ot "$f" ]]; then
    # Obsidian version is newer
    if git -C "/Users/divinejohns/Projects/repos/research-os" diff --quiet -- "$dst_file" 2>/dev/null; then
      # RO has no uncommitted changes — safe to overwrite into inbox for review
      ts=$(date +%Y%m%d%H%M%S)
      cp "$f" "$INBOX/${filename%.md}_newer_${ts}.md"
      log "NEWER: $filename (Obsidian newer, RO committed) → inbox"
    else
      # RO has uncommitted work — hard conflict
      echo "HARD CONFLICT: $filename — RO has uncommitted changes. Manual resolution required." >> "$CONFLICTS_LOG"
      log "HARD CONFLICT: $filename"
    fi
  else
    log "OK: $filename (RO version is current or newer)"
  fi
done

log "=== Obsidian import complete ==="
