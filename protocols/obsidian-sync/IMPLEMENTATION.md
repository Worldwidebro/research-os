# Obsidian Sync Protocol — Implementation

## Goal
Keep Research OS and Obsidian vault aligned as a two-way sync with Research OS as the canonical structured layer.

## Architecture

```
Obsidian Vault (~/Obsidian) ←→ Research OS (/research/markdown/) ←→ Neo4j
     human-readable                    structured markdown              graph
```

## Sync Direction

| Direction | Use Case | Mechanism |
|-----------|----------|-----------|
| Research OS → Obsidian | New questions, claims, evidence, hypotheses | Markdown export from schemas |
| Obsidian → Research OS | New notes, annotations, connections made in vault | Daily scan + triage agent |
| Bidirectional conflict | Same note edited in both places | Timestamp + human review for contradictions |

## Folder Mapping

| Research OS path | Obsidian path | Notes |
|-----------------|---------------|-------|
| `research/questions/*.md` | `Vault/Research/Questions/` | 1:1 sync |
| `schemas/*.json` | `Vault/Research/Schemas/` | Reference only |
| `memory/*.md` | `Vault/Research/Memory/` | 1:1 sync |
| `programs/*/README.md` | `Vault/Research/Programs/` | 1:1 sync |
| `knowledge/ontology/*.md` | `Vault/Research/Ontology/` | 1:1 sync |

## Export from Research OS → Obsidian

Script: `scripts/obsidian_export.sh`

```bash
#!/bin/bash
# Research OS → Obsidian export
# Run daily via cron or manually after commits

SRC="$HOME/Projects/repos/research-os"
DST="$HOME/Obsidian/Research"

# 1. Questions
mkdir -p "$DST/Questions"
cp "$SRC/research/questions/"*.md "$DST/Questions/"

# 2. Memory — decisions, lessons, debt
mkdir -p "$DST/Memory"
cp "$SRC/memory/"*.md "$DST/Memory/"

# 3. Programs
mkdir -p "$DST/Programs"
cp "$SRC/programs/"*/README.md "$DST/Programs/"

# 4. Ontology
mkdir -p "$DST/Ontology"
cp "$SRC/knowledge/ontology/"*.md "$DST/Ontology/"

# 5. Generate backlinks file (Obsidian-compatible)
cd "$DST/Questions"
for f in *.md; do
  # Extract [[links]] and write to .links file
  grep -o '\[\[[^]]*\]\]' "$f" | sed 's/\[\[//;s/\]\]//' | sort -u > "${f%.md}.links"
done

echo "Obsidian export complete: $(date)"
```

## Import from Obsidian → Research OS

Script: `scripts/obsidian_import.sh`

```bash
#!/bin/bash
# Obsidian → Research OS import
# Run daily. New/modified notes get triaged by the critic agent.

SRC="$HOME/Obsidian/Research/Questions"
DST="$HOME/Projects/repos/research-os/research/questions/"
INBOX="$HOME/Projects/repos/research-os/00_INBOX/obsidian/"

mkdir -p "$INBOX"

# Copy new/changed notes to inbox with timestamp
for f in "$SRC/"*.md; do
  [[ -f "$f" ]] || continue
  filename=$(basename "$f")
  dst_file="$DST/$filename"
  if [[ "$dst_file" -ot "$f" ]]; then
    cp "$f" "$INBOX/${filename%.md}_$(date +%Y%m%d%H%M%S).md"
    echo "New/changed: $filename → inbox"
  fi
done

# Triage: move existing files from inbox back to questions if they're ready
# (Triage agent decides — see agent READMEs)
```

## Conflict Detection

Conflict rule: if a note exists in both places and Obsidian version is newer, flag for human review before overwriting.

```bash
# In obsidian_import.sh, before copying:
dst_file="$DST/$filename"
if [[ -f "$dst_file" ]] && [[ "$dst_file" -ot "$f" ]]; then
  # Obsidian is newer — check if Research OS version has been committed
  if git -C "$HOME/Projects/repos/research-os" diff --quiet -- "$dst_file" 2>/dev/null; then
    # No uncommitted changes in RO — safe to overwrite
    cp "$f" "$INBOX/${filename%.md}_conflict_$(date +%Y%m%d).md"
    echo "CONFLICT: $filename (Obsidian newer, RO committed) → inbox for review"
  else
    # RO has uncommitted work — flag hard
    echo "HARD CONFLICT: $filename — RO has uncommitted changes. Manual resolution required." >> "$HOME/Projects/repos/research-os/00_INBOX/conflicts.log"
  fi
fi
```

## Agent Integration

The critic agent reads from `00_INBOX/obsidian/` daily and:
1. Classifies each note: question / claim / evidence / concept / noise
2. For questions: checks if RQ-ID exists; assigns new ID if needed
3. For claims: validates against schemas, assigns CL-ID
4. For evidence: links to source, assigns EV-ID
5. For concepts: checks ontology for existing CON-ID
6. Moves classified notes to correct Research OS folder
7. Opens PR or creates commit

## Backlink Convention

Research OS markdown files use `[[ID]]` syntax for graph references:

```markdown
# RQ-EDU-0001

## Competing Hypotheses
- [[HYP-EDU-0001]]
- [[HYP-EDU-0002]]

## Related Claims
- [[CL-0001]]
- [[CL-0002]]
```

Obsidian renders these as clickable links. The export script generates `.links` files for Obsidian's graph view.

## Cron Schedule

```
# Daily at 06:00 — export RO → Obsidian
0 6 * * * /Users/divinejohns/Projects/repos/research-os/scripts/obsidian_export.sh

# Daily at 22:00 — import Obsidian → RO inbox
0 22 * * * /Users/divinejohns/Projects/repos/research-os/scripts/obsidian_import.sh
```
