#!/usr/bin/env bash
# Research OS — Apple Notes export
# Exports Apple Notes to the inbox for triage.

set -euo pipefail

INBOX="/Users/divinejohns/Projects/repos/research-os/00_INBOX/apple-notes"
DATE_DIR="$INBOX/$(date +%Y-%m-%d)"
LOG="/Users/divinejohns/Projects/repos/research-os/00_INBOX/sync.log"

mkdir -p "$DATE_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

log "=== Apple Notes export starting ==="

# Method A: noteexporter CLI (preferred)
if command -v noteexporter &>/dev/null; then
  noteexporter export --format markdown --output "$DATE_DIR/" 2>/dev/null
  count=$(ls "$DATE_DIR/"*.md 2>/dev/null | wc -l)
  log "noteexporter: exported $count notes to $DATE_DIR/"
else
  # Method B: manual fallback — copy from a known export location
  # (User must set this up; see IMPLEMENTATION.md for options)
  FALLBACK="/Users/divinejohns/Library/Group Containers/group.com.apple.notes"
  if [[ -d "$FALLBACK" ]]; then
    find "$FALLBACK" -name "*.md" -newer "$DATE_DIR/../export-marker" -exec cp {} "$DATE_DIR/" \; 2>/dev/null || true
    count=$(ls "$DATE_DIR/"*.md 2>/dev/null | wc -l)
    log "fallback: copied $count notes from Apple Notes container"
  else
    log "WARNING: no export method available. Set up noteexporter or manual export."
  fi
fi

# Touch marker for next run's "newer than" comparison
touch "$DATE_DIR/../export-marker"

log "=== Apple Notes export complete ==="
