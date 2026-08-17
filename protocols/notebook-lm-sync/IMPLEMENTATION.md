# Notebook LM Sync Protocol — Implementation

## Goal
Use Notebook LM as an analysis layer for uploaded documents, with extracted insights flowing back to Research OS as structured objects. No knowledge lives only in Notebook LM.

## Architecture

```
Research OS                        Notebook LM                    Research OS
(source docs)  ─────────────────→  (analysis)  ────────────────→  (insights)
   schemas/                         (source-pinned                 CLAIM/
   research/                          Q&A)                          CONCEPT/
   papers/                           (insight extraction)           EVIDENCE/
        │                                                              objects)
        └─────────────────────── provenance tracking ───────────────────┘
                                SOURCE node
```

## Notebook LM as Analysis Layer

Notebook LM is used for three things:

1. **Document Q&A**: Ask questions about a set of uploaded sources and get cited answers
2. **Insight extraction**: Surface connections, contradictions, and patterns across documents
3. **Audio overview**: Quick audio summary of a research area (optional output)

## What Goes INTO Notebook LM

| Research OS folder | Notebook LM use |
|-------------------|----------------|
| `research/papers/` | Upload as sources for Q&A |
| `schemas/*.json` | Reference for structured objects |
| `research/questions/*.md` | Context for question-driven analysis |
| External PDFs | Upload directly as sources |

## What Comes OUT OF Notebook LM

Every insight extracted from Notebook LM must be captured in Research OS with provenance.

### Output object types

| Notebook LM output | Research OS object | ID prefix |
|-------------------|-------------------|-----------|
| Factual claim from a source | `Claim` | CL- |
| Concept defined in source | `Concept` | CON- |
| Evidence quote with citation | `Evidence` | EV- |
| Source used in analysis | `Source` | SRC- |
| Synthesized connection | `Insight` | INS- |
| Question raised by analysis | `Question` | RQ- |

## Extraction Workflow

### Step 1: Upload sources

```bash
# Export source documents to a Notebook LM-compatible folder
mkdir -p /tmp/notebooklm-sources/$(date +%Y%m%d)
cp research/papers/*.pdf /tmp/notebooklm-sources/$(date +%Y%m%d)/
cp research/questions/RQ-*.md /tmp/notebooklm-sources/$(date +%Y%m%d)/

# Log what was uploaded
echo "$(date): uploaded $(ls /tmp/notebooklm-sources/$(date +%Y%m%d)/ | wc -l) files" \
  >> /tmp/notebooklm-upload-history.log
```

### Step 2: Ask targeted questions

Questions to ask Notebook LM (captures most insight types):

```
# Evidence extraction
"List every statistical claim made in these documents with their exact citations."

# Contradiction detection
"Identify any places where these documents disagree with each other."

# Concept mapping
"What key concepts appear across multiple documents? Define each one."

# Gap identification
"What questions do these documents leave unanswered?"

# Synthesis
"What is the strongest argument across all these documents for [research question]?"
```

### Step 3: Capture outputs

Each answer is saved as a structured markdown note in:

```
00_INBOX/notebook-lm/
├── 2026-08-15/
│   ├── 20260815_evidence-extraction.md
│   ├── 20260815_contradictions.md
│   ├── 20260815_concepts.md
│   └── 20260815_gaps.md
```

Frontmatter template:

```markdown
---
id: NL-0001
type: notebook-lm-extraction
date: 2026-08-15
question_asked: "List every statistical claim made in these documents with their exact citations."
sources_uploaded:
  - paper1.pdf
  - paper2.pdf
status: pending-review
---

## Extraction

[Copy Notebook LM answer here verbatim]

## Proposed Research OS Objects

| Type | Proposed ID | Statement |
|------|-------------|-----------|
| Claim | CL-0006 | ... |
| Evidence | EV-0006 | ... |
| Concept | CON-0007 | ... |

## Reviewer Notes

[To be filled by critic agent or human]
```

### Step 4: Triage and promote

The critic agent processes `00_INBOX/notebook-lm/` daily and:
1. Reviews each extraction
2. Creates proper Research OS objects (CL-, EV-, CON-, INS-)
3. Links objects to their Notebook LM source note
4. Marks Notebook LM note as `reviewed`
5. Opens PR or creates commit

## Provenance Tracking

Every object created from Notebook LM analysis carries:

```json
{
  "source": "notebook-lm",
  "notebook_lm_date": "2026-08-15",
  "notebook_lm_question": "List every statistical claim...",
  "sources_uploaded": ["paper1.pdf", "paper2.pdf"],
  "extraction_note": "NL-0001",
  "confidence": 0.72
}
```

This makes it possible to trace any claim back to the original Notebook LM session and question.

## Prohibition

**No knowledge lives only in Notebook LM.**

If an insight exists in Notebook LM but not in Research OS, it is considered lost. The critic agent enforces this by checking that every active NLL extraction note has corresponding Research OS objects.

Check script:

```bash
#!/bin/bash
# scripts/notebook-lm-audit.sh

INBOX="/Users/divinejohns/Projects/repos/research-os/00_INBOX/notebook-lm"
RESEARCH="/Users/divinejohns/Projects/repos/research-os"

echo "=== Notebook LM Audit ==="
echo "Date: $(date)"

# Find un-reviewed extraction notes
unreviewed=$(find "$INBOX" -name "*.md" -exec grep -l "status: pending-review" {} \;)
if [[ -n "$unreviewed" ]]; then
  echo "⚠ Unreviewed extractions:"
  echo "$unreviewed"
else
  echo "✓ All extractions reviewed"
fi

echo ""
echo "=== Extracted Objects by Type ==="
for type in Claim Evidence Concept Insight Question; do
  count=$(find "$RESEARCH" -name "*.md" -exec grep -l "\"type\": \"$type\"" {} \; | wc -l)
  echo "$type: $count objects"
done
```

## Cron Schedule

```
# Weekly on Sunday at 10:00 — audit Notebook LM backlog
0 10 * * 0 /Users/divinejohns/Projects/repos/research-os/scripts/notebook-lm-audit.sh
```
