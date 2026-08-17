#!/usr/bin/env bash
# Research OS — Obsidian export
# Runs daily via cron or manually after commits
# Exports structured Research OS objects to Obsidian vault

set -euo pipefail

SRC="/Users/divinejohns/Projects/repos/research-os"
DST="/Users/divinejohns/Obsidian/Research"
LOG="/Users/divinejohns/Projects/repos/research-os/00_INBOX/sync.log"

mkdir -p "$DST"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

log "=== Obsidian export starting ==="

# 1. Questions
mkdir -p "$DST/Questions"
cp "$SRC/research/questions/"*.md "$DST/Questions/" 2>/dev/null || true
log "Questions: $(ls "$DST/Questions/"*.md 2>/dev/null | wc -l) files"

# 2. Memory
mkdir -p "$DST/Memory"
cp "$SRC/memory/"*.md "$DST/Memory/" 2>/dev/null || true
log "Memory: $(ls "$DST/Memory/"*.md 2>/dev/null | wc -l) files"

# 3. Programs
mkdir -p "$DST/Programs"
for prog in "$SRC/programs/"*/README.md; do
  [[ -f "$prog" ]] || continue
  cp "$prog" "$DST/Programs/"
done
log "Programs: $(ls "$DST/Programs/"*.md 2>/dev/null | wc -l) files"

# 4. Ontology
mkdir -p "$DST/Ontology"
if [[ -d "$SRC/knowledge/ontology" ]]; then
  cp "$SRC/knowledge/ontology/"*.md "$DST/Ontology/" 2>/dev/null || true
fi
log "Ontology: $(ls "$DST/Ontology/"*.md 2>/dev/null | wc -l) files"

# 5. Syntheses
mkdir -p "$DST/Syntheses"
cp "$SRC/research/syntheses/"*.md "$DST/Syntheses/" 2>/dev/null || true
log "Syntheses: $(ls "$DST/Syntheses/"*.md 2>/dev/null | wc -l) files"

# 6. Generate .links files for Obsidian graph view
cd "$DST/Questions"
for f in *.md; do
  [[ -f "$f" ]] || continue
  grep -o '\[\[[^]]*\]\]' "$f" 2>/dev/null | sed 's/\[\[//;s/\]\]//' | sort -u > "${f%.md}.links" 2>/dev/null || true
done
log "Backlinks generated"

log "=== Obsidian export complete ==="
