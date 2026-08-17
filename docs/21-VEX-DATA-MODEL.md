# VEX Data Model

**Last updated:** 2026-08-17  
**Status:** Design. Awaiting infrastructure connection.

---

## Purpose

VEX (vex-site) is the public-facing venture portal for Worldwidebro / Civilization OS. It shows what ventures exist, what they do, and their status. It pulls from the infrastructure (Neo4j, Postgres, Qdrant), not from scattered drive folders.

VEX is the front door. The infrastructure is the back office.

---

## Public Data Model

### VEX_VENTURE

| Field | Type | Description |
|-------|------|-------------|
| id | string | Venture identifier (e.g. "CON-001", "LT-005") |
| name | string | Display name (e.g. "Ace Construction") |
| tagline | string | One-line description |
| sector | string | Sector slug (e.g. "construction", "logistics") |
| status | enum | `live` / `building` / `idea` / `archived` |
| description | string | 1-3 sentence description |
| demo_url | string? | Link to live demo or site (if exists) |
| repo_url | string? | GitHub repo URL (if public) |
| updated_at | datetime | Last status change |
| source_path | string | Internal: T7 or LaCie path (not displayed) |

### VEX_SECTOR

| Field | Type | Description |
|-------|------|-------------|
| id | string | Sector slug |
| name | string | Display name |
| venture_count | integer | Number of ventures in sector |
| description | string | What the sector covers |

### VEX_STATUS (computed)

| Field | Type | Description |
|-------|------|-------------|
| venture_id | string | FK to VEX_VENTURE |
| has_dashboard | boolean | Does the venture have an operational dashboard |
| has_revenue | boolean | Is the venture generating revenue |
| last_active | datetime | Last activity timestamp |
| completion_percentage | float | 0-100 estimated completion |

---

## Internal Data Model (not on VEX)

### VENTURE_FINANCIALS

| Field | Type |
|-------|------|
| venture_id | string |
| monthly_revenue | decimal |
| monthly_costs | decimal |
| margin | decimal |
| currency | string |
| period | date |

### VENTURE_CUSTOMERS

| Field | Type |
|-------|------|
| venture_id | string |
| customer_id | string |
| name | string |
| email | string |
| status | enum(prospect, active, churned) |
| value | decimal |
| source | string |

### VENTURE_AGENTS

| Field | Type |
|-------|------|
| venture_id | string |
| agent_id | string |
| role | string |
| capability | string |
| status | enum(active, idle, deprecated) |
| config_path | string |

### VENTURE_PEOPLE

| Field | Type |
|-------|------|
| venture_id | string |
| person_id | string |
| name | string |
| role | string |
| involvement | enum(owner, manager, contractor, employee) |

### VENTURE_IP

| Field | Type |
|-------|------|
| venture_id | string |
| ip_name | string |
| description | string |
| status | enum(patented, pending, trade-secret, unprotected) |

---

## Data Sources

VEX reads from:

1. **Neo4j** — relationship queries (venture → sector, venture → people, venture → status)
2. **Postgres / NocoDB** — structured venture records
3. **Qdrant** — semantic search across venture descriptions
4. **venture_registry.json** (T7) — seed data for initial population

VEX does NOT read from:
- T7 Shield directly
- LaCie directly
- Scattered drive folders

Those are source material. The infrastructure is the queryable layer.

---

## Sync Model

```
SOURCE (T7, LaCie, Obsidian, Apple Notes)
    │
    ▼
  INGESTION PIPELINE (cron / event-driven)
    │
    ├→ Neo4j (relationships)
    ├→ Postgres (structured records)
    ├→ Qdrant (semantic vectors)
    └→ MinIO (raw objects)
    │
    ▼
  VEX reads from infrastructure APIs
    │
    ▼
  VEX renders public venture portal
```

VEX is read-only from the infrastructure. Writes happen through the ingestion pipeline or direct infrastructure edits.

---

## Example VEX Pages

### Venture listing (home)

Grid of venture cards grouped by sector. Each card shows: name, tagline, status badge, sector.

### Sector page

List of all ventures in a sector with summary stats (count, active count, revenue-generating count).

### Venture detail page

Full public description, status, demo link, repo link, related ventures, people (public roles only).

### About / ecosystem page

What Worldwidebro / Civilization OS is, how the venture system works, the infrastructure behind it.

---

## Implementation Notes

- VEX is Vite/TypeScript (existing repo: `~/Projects/repos/vex-site`)
- Has `vercel.json` — deployable to Vercel
- Currently dev server on port 5173
- Data fetching: static generation at build time + client-side hydration for dynamic status
- Status data can be fetched at build time from infrastructure APIs (Neo4j HTTP, Postgres query)
- For real-time status, add a lightweight API endpoint that queries infrastructure
