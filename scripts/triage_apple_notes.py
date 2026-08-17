#!/usr/bin/env python3
"""
Research OS — Apple Notes triage agent
Classifies notes from the Apple Notes inbox into Research OS types.
Usage: python3 scripts/triage_apple_notes.py
"""

import re
import sys
import json
from pathlib import Path
from datetime import datetime

INBOX = Path("/Users/divinejohns/Projects/repos/research-os/00_INBOX/apple-notes")
RESEARCH_OS = Path("/Users/divinejohns/Projects/repos/research-os")
REVIEW_DIR = Path("/Users/divinejohns/Projects/repos/research-os/00_INBOX/review")
LOG = RESEARCH_OS / "00_INBOX/triage.log"

# Domain prefix map for ID assignment
DOMAIN_PREFIX = {
    "edu-core": "EDU",
    "logistics": "LT",
    "vex-core": "VEX",
    "ai-agents": "AI",
}

# Track next IDs per domain
_next_id = {domain: 1 for domain in DOMAIN_PREFIX}


def load_next_ids():
    """Load the next IDs from existing files to avoid collisions."""
    global _next_id
    for path in RESEARCH_OS.rglob("*.md"):
        text = path.read_text()
        # Find the highest existing ID per domain
        for domain, prefix in DOMAIN_PREFIX.items():
            matches = re.findall(rf'id:\s*{prefix}-\d+', text)
            for m in matches:
                num = int(m.split('-')[1])
                if num >= _next_id[domain]:
                    _next_id[domain] = num + 1


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


def assign_domain(text: str) -> str:
    """Guess the domain from note content."""
    text_lower = text.lower()
    if re.search(r'(education|learning|student|teaching|pedagogy|spaced|retention|vocational|training)', text_lower):
        return 'edu-core'
    if re.search(r'(logistics|delivery|courier|route|driver|transport|supply|last-mile|medical courier)', text_lower):
        return 'logistics'
    if re.search(r'(venture|business|startup|revenue|metric|growth|ecosystem| worldwidebro|vex)', text_lower):
        return 'vex-core'
    if re.search(r'(agent|llm|autonomous|memory|planning|ai)', text_lower):
        return 'ai-agents'
    return 'vex-core'  # default


def assign_id(domain: str, note_type: str) -> str:
    """Assign the next available ID."""
    prefix = DOMAIN_PREFIX.get(domain, "UNK")
    type_map = {
        'question': 'RQ',
        'claim': 'CL',
        'evidence': 'EV',
        'concept': 'CON',
        'hypothesis': 'HYP',
    }
    type_prefix = type_map.get(note_type, 'XX')
    num = _next_id[domain]
    _next_id[domain] += 1
    return f"{type_prefix}-{prefix}-{num:04d}"


def generate_frontmatter(note_type: str, domain: str, note_id: str, source_file: str, text: str) -> str:
    """Generate YAML frontmatter for the promoted note."""
    now = datetime.now().strftime('%Y-%m-%d')

    templates = {
        'question': f"""---
id: {note_id}
type: research-question
status: active
priority: medium
domain: {domain}
created: {now}
source: apple-notes
original_note: {source_file}
---

""",
        'claim': f"""---
id: {note_id}
type: claim
status: claim
confidence: 0.50
domain: {domain}
created: {now}
source: apple-notes
original_note: {source_file}
---

""",
        'evidence': f"""---
id: {note_id}
type: evidence
status: pending-review
domain: {domain}
created: {now}
source: apple-notes
original_note: {source_file}
---

""",
        'concept': f"""---
id: {note_id}
type: concept
label: "{text.split(chr(10))[0].strip()}"
domain: {domain}
created: {now}
source: apple-notes
original_note: {source_file}
---

""",
        'hypothesis': f"""---
id: {note_id}
type: hypothesis
status: proposed
domain: {domain}
created: {now}
source: apple-notes
original_note: {source_file}
---

""",
    }
    return templates.get(note_type, f"""---
id: {note_id}
type: {note_type}
status: pending-review
domain: {domain}
created: {now}
source: apple-notes
original_note: {source_file}
---

""")


def promote_note(note_path: Path, note_type: str, domain: str, note_id: str):
    """Promote a classified note to its Research OS destination."""
    text = note_path.read_text()

    # Determine destination
    dest_map = {
        'question': RESEARCH_OS / 'research/questions',
        'claim': RESEARCH_OS / 'research/claims',
        'evidence': RESEARCH_OS / 'research/evidence',
        'concept': RESEARCH_OS / 'knowledge/ontology/concepts',
        'hypothesis': RESEARCH_OS / 'research/hypotheses',
    }
    dest_dir = dest_map.get(note_type, RESEARCH_OS / '00_INBOX/review')
    dest_dir.mkdir(parents=True, exist_ok=True)

    dest_file = dest_dir / f"{note_id}.md"
    if dest_file.exists():
        # Collision — append timestamp
        ts = datetime.now().strftime('%Y%m%d%H%M%S')
        dest_file = dest_dir / f"{note_id}_{ts}.md"

    frontmatter = generate_frontmatter(note_type, domain, note_id, note_path.name, text)
    dest_file.write_text(frontmatter + text)

    # Move original to processed
    processed_dir = INBOX / 'processed'
    processed_dir.mkdir(parents=True, exist_ok=True)
    note_path.rename(processed_dir / note_path.name)

    return dest_file


def main():
    load_next_ids()

    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    def log(msg: str):
        ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        line = f"[{ts}] {msg}"
        LOG.open('a').write(line + '\n')
        LOG.open('a').flush()
        print(line, file=sys.stderr)

    log(f"=== Triage run: {timestamp} ===")

    if not INBOX.exists():
        log("Inbox does not exist. Nothing to triage.")
        return

    notes = sorted(INBOX.glob("*.md"))

    if not notes:
        log("No notes in inbox.")
        return

    results = []

    for note_path in notes:
        text = note_path.read_text()
        note_type = classify_note(text)
        domain = assign_domain(text)
        note_id = assign_id(domain, note_type)

        result = {
            'file': str(note_path),
            'classification': note_type,
            'domain': domain,
            'assigned_id': note_id,
            'preview': text[:200].replace('\n', ' '),
        }
        results.append(result)

        if note_type == 'disposition':
            # Move to review queue
            REVIEW_DIR.mkdir(parents=True, exist_ok=True)
            review_file = REVIEW_DIR / note_path.name
            note_path.rename(review_file)
            log(f"REVIEW: {note_path.name} → review queue (disposition)")
        else:
            dest = promote_note(note_path, note_type, domain, note_id)
            log(f"PROMOTE: {note_path.name} → {dest.name} [{note_type}/{domain}]")

    # Print JSON for agent consumption
    print(json.dumps(results, indent=2))


if __name__ == '__main__':
    main()
