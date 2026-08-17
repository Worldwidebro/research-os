# Apple Notes Sync Protocol — Implementation

## Goal
Capture mobile notes from Apple Notes into Research OS and triage them into structured objects.

## Architecture

```
Apple Notes (iOS/Mac) → Daily batch export → 00_INBOX/apple-notes/
                                                         ↓
                                              Triage agent (critic)
                                                         ↓
                                        Classification → Research OS folder
```

## Why Apple Notes is the Capture Layer

- Fastest capture on mobile
- Available everywhere (iPhone, iPad, Mac)
- No friction — just type and it's there
- Research OS is the archive; Apple Notes is the inbox

## Export from Apple Notes

Option A: `noteexporter` CLI (recommended for automation)

```bash
# Install
brew install noteexporter

# Export all notes as markdown to stdout
noteexporter export --format markdown --output - > /tmp/apple-notes-export.md

# Export with folder structure
noteexporter export --format markdown --output "$HOME/00_INBOX/apple-notes/"
```

Option B: Apple Notes attachments folder (manual)

```bash
# Apple Notes stores attachments in:
# ~/Library/Group Containers/group.com.apple.notes/

# Search for recent .md or .txt exports from Notes-compatible apps
find ~/Library/Group\ Containers/group.com.apple.notes -name "*.md" -newer /tmp/apple-notes-last-export -exec cp {} /tmp/apple-notes-raw/ \;
```

Option C: Shortcut automation (iOS) — export a folder to iCloud Drive, then sync to Mac

```
iOS Shortcut: "Notes to Research OS"
1. Get notes from "Inbox" folder (sorted by date modified, newest first)
2. Convert each to markdown
3. Save to iCloud Drive /ResearchOS/Inbox/
4. Mac picks up from iCloud Drive
```

## Inbox Structure

```
00_INBOX/apple-notes/
├── 2026-08-15/
│   ├── 20260815_142301_academic-sentence-reading.md
│   ├── 20260815_150211_vr-training-idea.md
│   └── 20260815_163044_logistics-metric-question.md
├── 2026-08-16/
└── unprocessed.log  # notes not yet triaged
```

## Triage Agent Rules

The critic agent processes the inbox daily (see `agents/critic/README.md`).

Classification rules:

| Signal | Classification | Action |
|--------|---------------|--------|
| Contains `?` + question structure | Question | Create RQ-ID, link to domain |
| Contains `claim:` or `believe:` prefix | Claim | Validate, create CL-ID |
| References a paper/book/source | Evidence | Link to source, create EV-ID |
| Defines a term or model | Concept | Add to ontology, create CON-ID |
| Vague idea, no clear type | Disposition | Keep in inbox, flag for human review |
| Duplicate of existing note | Duplicate | Link to original, archive |

## Classification Script

```python
#!/usr/bin/env python3
# scripts/triage_apple_note.py

import re
import sys
from pathlib import Path

def classify_note(text: str) -> str:
    """Classify an Apple Note into a Research OS type."""
    text_lower = text.lower()

    # Question signals
    if re.search(r'\b(how|why|what|when|where|does|do|can|will|should)\b.*\?', text_lower):
        return 'question'

    # Claim signals
    if re.search(r'(claim|believe|evidence shows|studies find|research indicates|we know)\b', text_lower):
        return 'claim'

    # Evidence signals (references to sources)
    if re.search(r'(paper|study|source|doi|et al|journal|volume|pp\.|research by)\b', text_lower):
        return 'evidence'

    # Concept signals (defining something)
    if re.search(r'(definition|refers to|means|is a type of|consists of|is defined as)\b', text_lower):
        return 'concept'

    # Hypothesis signals
    if re.search(r'(hypothesis|predict|if.*then|would expect|should see)\b', text_lower):
        return 'hypothesis'

    return 'disposition'

def main():
    if len(sys.argv) < 2:
        print("Usage: triage_apple_note.py <note_file>")
        sys.exit(1)

    note_path = Path(sys.argv[1])
    text = note_path.read_text()

    classification = classify_note(text)

    print(f"{note_path.name}: {classification}")

    # Output structured JSON for agent consumption
    import json
    print(json.dumps({
        'file': str(note_path),
        'classification': classification,
        'preview': text[:200]
    }, indent=2))

if __name__ == '__main__':
    main()
```

## Promotion to Research OS

When a note is classified and promoted:

```bash
# Questions
cp 00_INBOX/apple-notes/2026-08-15/20260815_142301_academic-sentence-reading.md \
   research/questions/RQ-EDU-0003.md
# Add frontmatter
cat >> research/questions/RQ-EDU-0003.md << 'EOF'
---
id: RQ-EDU-0003
type: research-question
status: active
priority: medium
domain: edu-core
created: 2026-08-15
source: apple-notes
original_note: 20260815_142301_academic-sentence-reading.md
---
EOF

# Claims
cp ... → research/claims/CL-0006.md  (similar frontmatter)

# Concepts
cp ... → knowledge/ontology/concepts/CON-0007.md
```

## Cron Schedule

```
# Daily at 07:00 — export Apple Notes → inbox
0 7 * * * /Users/divinejohns/Projects/repos/research-os/scripts/apple_notes_export.sh

# Daily at 08:00 — triage inbox
0 8 * * * python3 /Users/divinejohns/Projects/repos/research-os/scripts/triage_apple_notes.py /Users/divinejohns/Projects/repos/research-os/00_INBOX/apple-notes/ >> /Users/divinejohns/Projects/repos/research-os/00_INBOX/triage.log
```

## Human Review Queue

Notes that the classifier marks as `disposition` go to:

```
00_INBOX/review/
```

The research-director agent surfaces these during daily standup for human decision.
