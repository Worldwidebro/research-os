#!/usr/bin/env bash
# Research OS — Notebook LM audit
# Checks for unreviewed extractions and reports object counts by type.

set -euo pipefail

INBOX="/Users/divinejohns/Projects/repos/research-os/00_INBOX/notebook-lm"
RESEARCH="/Users/divinejohns/Projects/repos/research-os"
LOG="/Users/divinejohns/Projects/repos/research-os/00_INBOX/sync.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

log "=== Notebook LM Audit ==="
log "Date: $(date)"

# Find unreviewed extraction notes
unreviewed=$(find "$INBOX" -name "*.md" -exec grep -l "status: pending-review" {} \; 2>/dev/null || true)
if [[ -n "$unreviewed" ]]; then
  log "⚠ Unreviewed extractions ($(...), count: $(echo "$unreviewed" | wc -l | tr -d ' '))"
  echo "$unreviewed" | while read -r f; do
    log "  → $(basename "$f")"
  done
else
  log "✓ All extractions reviewed"
fi

log ""
log "=== Extracted Objects by Type ==="

# Count by schema type
declare -A counts
counts[Claim]=0
counts[Evidence]=0
counts[Concept]=0
counts[Insight]=0
counts[Question]=0
counts[Hypothesis]=0
counts[Source]=0

for type in Claim Evidence Concept Insight Question Hypothesis Source; do
  c=$(find "$RESEARCH" -name "*.md" -exec grep -l "\"type\": \"$type\"" {} \; 2>/dev/null | wc -l | tr -d ' ')
  counts[$type]=$c
  log "$type: $c"
done

log ""
total=$(( ${counts[Claim]} + ${counts[Evidence]} + ${counts[Concept]} + ${counts[Insight]} + ${counts[Question]} + ${counts[Hypothesis]} + ${counts[Source]} ))
log "Total objects: $total"

# Check for Notebook LM notes with no corresponding Research OS objects
log ""
log "=== Orphaned Notebook LM Notes ==="
orphans=$(find "$INBOX" -name "*.md" -exec grep -l "type: notebook-lm-extraction" {} \; 2>/dev/null || true)
if [[ -n "$orphans" ]]; then
  echo "$orphans" | while read -r f; do
    # Check if this extraction has been reviewed
    if grep -q "status: reviewed" "$f" 2>/dev/null; then
      continue
    fi
    log "  Orphan: $(basename "$f") — not yet reviewed"
  done
else
  log "✓ No orphaned extractions"
fi

log "=== Audit complete ==="
