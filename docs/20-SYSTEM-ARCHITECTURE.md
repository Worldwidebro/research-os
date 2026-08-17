# System Architecture — Worldwidebro Civilization OS

**Last updated:** 2026-08-17  
**Status:** Observed and documented. Implementation in progress.

---

## The Problem

Worldwidebro has a fully built infrastructure substrate (21 Docker containers, Tailscale private network, Hermes agent orchestration) sitting idle. Venture knowledge and files are scattered across T7 Shield and LaCie with no ingestion layer connecting them. The infrastructure is ready — it has nothing to work on yet.

## The Architecture

```
              VENTURE SOURCE MATERIAL
                     │
        ┌────────────┼────────────┐
        ▼            ▼             ▼
     T7 Shield     LaCie       Other sources
   (primary)    (archive)     (Obsidian, Apple Notes)
        │            │             │
        └────────────┴────────────┘
                     │
                     ▼
              FILE DISCOVERY
        venture archaeology inventory
                     │
                     ▼
              DOCUMENT PARSING
                     │
        ┌────────────┼────────────┐
        ▼            ▼             ▼
   STRUCTURED     UNSTRUCTURED    OBJECTS
        │            │             │
        ▼            ▼             ▼
   Postgres      Qdrant        MinIO
   NocoDB                        (raw files)
        │            │             │
        └────────────┴────────────┘
                     │
                     ▼
                  Neo4j
          relationships + graph
                     │
        ┌────────────┼────────────┐
        ▼            ▼             ▼
   Ventures      People      Capabilities
        │            │             │
        └────────────┴────────────┘
                     │
                     ▼
                  Agents
                     │
                     ▼
                   Work
                     │
                     ▼
                Outcomes
                     │
                     ▼
              New Knowledge
                     │
                     └──────→ Neo4j / Qdrant
```

## What Exists Where

### T7 Shield (primary venture system — 947GB used, 916GB free)

**Three venture layers:**

1. **`/01_VENTURES/`** — 16 sector launch templates
   - Sectors: 01-beauty-wellness through 16-technology
   - Each sector has: `_assets/`, `_data/`, `_presell/`, `_tasks/`
   - Purpose: standardized venture launch pipeline

2. **`/01_VENTURES/_hub/`** — The Venture Hub (canonical registry)
   - `venture_registry.json` — 53 ventures cataloged with metadata (name, path, sector, status, files, has_dashboard, has_revenue)
   - `MONETIZATION_REGISTRY.yaml` — 8 monetization archetypes (product, digital_product, service, attention, subscription, marketplace, licensing, advertising)
   - `active/` — 36 currently executing ventures
   - `archived/` — 12 archived ventures
   - 129 total venture directories
   - `_analytics/` — cross-venture analytics data
   - `_automation/` — GitHub venture builder, scripts
   - `_build/` — build pipelines
   - `_dashboards/` — venture dashboards
   - `_network/` — network maps, stakeholders
   - `_observability/` — dashboards, logs, scripts
   - Connected to Supabase (cyhzilqldouzgynacqpe), GitHub (acebless/*), Next.js venture dashboard

3. **`/14_INFRASTRUCTURE/CivOS/01-ventures/`** — Full venture execution set (163 ventures)
   - BW-*: Beauty/wellness (BW-001-Lash-Extension-Studio, BW-010-Online-Lash-Education, BW-023-Mobile-Hairstyling)
   - EC-*: E-commerce (EC-044-Live-Commerce-Platform, EC-051-AI-Email-Marketing, EC-054-AI-Demand-Forecasting)
   - ET-*: Education/training (ET-009-Resume-Writing-Service, ET-010-Interview-Prep-Platform)
   - FH-*: Food/hospitality (FH-001-Personal-Chef-Service, FH-002-Meal-Prep-Delivery)
   - FIN-*: Financial (FIN-001-GenixBank-Lite, FIN-002-Credit-Repair-Automation, FIN-008-Business-Formation, FIN-036-Arbitrage-Nexus-Platform)
   - FIT-*: Fitness (FIT-001-Personal-Training-Studio)
   - LOG-*: Logistics (LOG-001-Freight-Dispatch, LOG-004-HVAC-Technician-Dispatch, LOG-030-Truck-Dispatch-Company)
   - MC-*: Media/content (MC-001-YouTube-Channel-Network, MC-002-Podcast-Network, MC-003-Blog-Network, MC-017-Online-Course-Platform, MC-018-Membership-Site, MC-019-Digital-Download-Store)
   - PS-*: Professional services (PS-001-Business-Consulting, PS-003-Accounting-Services, PS-005-Marketing-Agency, PS-006-Web-Design-Agency, PS-008-Virtual-Assistant, PS-009-Bookkeeping-Service, PS-010-Tax-Prep-Service, PS-020-Social-Media-Management, PS-021-SEO-Agency)
   - RE-*: Real estate (RE-001-Real-Estate-Wholesaling)
   - ST-*: Software/technology (ST-001-SaaS-Platform-Template, ST-008-Cybersecurity-Service, ST-017-Chatbot-Builder, ST-024-Marketing-Automation, ST-025-Sales-Automation)

**Other T7 layers:**
- `/00_COMMAND_CENTER/` — Civilization-OS orchestrator, civilization-shared, Obsidian vault, global configs
- `/02_AUTOMATIONS/` through `/20_ARCHIVE/` — 20 numbered top-level directories covering everything from automations to acquisitions
- `/20_ARCHIVE/20-ventures/` — Historical venture archive with sectors, businesses, companies, idea-pipeline, pitch-decks, etc.
- `/20_ARCHIVE/obsidian-vault-local/` — Archived Obsidian vault with venture notes

### LaCie (knowledge archive — 1.6TB used, 2.1TB free)

- **SecondBrain/** — Git-tracked knowledge base (600+ numbered directories in CivilizationOS-Archive)
  - Business/Ventures — fin-ventures-index.md, tech-ventures-index.md (only 2 index files)
  - Civilization OS/ventures — minimal (avs478-workflows)
  - CivilizationOS-Archive/ — vast historical archive, fragmented knowledge
  - Agents/, Dev-Tools/, Education/, Finance/, Clients/, Github Repos/, Storage-Databases/
- **DEVELOPMENT-ECOSYSTEM/** — Development work
- **RESEARCH-LAB/** — Research outputs
- **OLLAMA/** and **ollama-models/** — Model storage

### Docker Infrastructure (21 containers, all idle for ventures)

| Container | Role | Port |
|-----------|------|------|
| civos_neo4j | Knowledge graph | 7474, 7687 |
| civos_qdrant | Semantic vector retrieval | 6333 |
| civos_minio | Object storage (S3) | 9000, 9001 |
| crm-postgres | CRM data | 5434 |
| buzz-postgres | Secondary DB | 5433 |
| buzz-redis | Cache/queue | 6379 |
| civos_redis | Redis alt | 6380 |
| n8n | Workflow automation | 5678 |
| civos_twenty | CRM (Twenty) | 3004 |
| civos_nocodb | Operational tables | 8090 |
| civos_mcpjungle | Tool connectivity | 8787 |
| civos_omniroute | Model routing | 20128 |
| civos_litellm | LLM proxy | 4000 |
| civos_langfuse | AI observability | 3003 |
| civos_webui | Open WebUI | 3010 |
| civos_changedetection | Change monitoring | 5001 |
| civos_infisical | Secret management | 8091 |
| civos_infisical_mongo | Mongo for Infisical | 27017 |
| spinup-immich-server | Photo/media | 2283 |
| spinup-nextcloud | File sync | 8081 |
| spinup-vercel-eve | Vercel sandbox | — |

**Key finding:** None of these containers run venture-specific applications. Infrastructure is clean and separate from venture layer.

### Tailscale (private network — 5 nodes)

| Node | IP | Status | Notes |
|------|-----|--------|-------|
| Mac Studio | 100.87.214.70 | online | Primary workstation |
| Mac Air (aces-macbook-air-1) | 100.121.17.63 | online | SSH broken — daemon closes after banner |
| iPad (ipad-10th-gen-wificellular) | 100.110.180.123 | offline | Last seen 33d ago |
| iMac (divines-imac) | 100.126.240.61 | offline | 157d ago |
| iPhone (dexterslab) | 100.126.240.124 | offline | — |

No Tailscale file server running.

### Knowledge Tools

- **Obsidian:** Two vaults (~37K + ~14K markdown files). No venture-named notes found in either.
- **Apple Notes:** Export script exists (`scripts/apple_notes_export.sh`, `triage_apple_notes.py`). Not integrated.
- **NotebookLM:** No local installation or data found. Audit script exists but no data.
- **Hermes/gbrain:** MCP-wired, brain initialized, Obsidian vault import pending.

## The Gap

```
INFRASTRUCTURE (READY)
     │
     ├── databases (Neo4j, Postgres, Qdrant, MinIO)
     ├── networking (Tailscale)
     ├── observability (Langfuse, n8n)
     ├── identity (Infisical)
     ├── orchestration (Hermes, gbrain)
     └── automation (n8n, MCPJungle)
              │
              ▼
       VENTURE PLATFORM (NOT BUILT)
              │
       ┌──────┼──────┐
       ▼      ▼      ▼
     VEX    Venture B Venture C
       │
       ▼
    Agents
       │
       ▼
     Work
```

The gap is not infrastructure. It's the **ingestion and connection layer** between scattered venture files and the idle infrastructure.

## The Strategy

**Step 1: Venture Archaeology**
Inventory every venture directory across T7 + LaCie. Extract canonical metadata from existing registry files (venture_registry.json has 53 entries with structured metadata). Deduplicate. Classify as active/archived/duplicate. Do NOT move files yet.

**Step 2: Canonical Registry**
Generate `VENTURE-MASTER-REGISTRY.csv` from evidence (the existing registry.json + archaeology). One row per canonical venture with: ID, name, sector, status, description, source path, repo URL, has_dashboard, has_revenue, people, capabilities, relationships.

**Step 3: Ingestion Pipeline**
Wire the existing scripts (`obsidian_export.sh`, `apple_notes_export.sh`, `notebook-lm-audit.sh`) into a full pipeline:
- File discovery → parse → structured (Postgres/NocoDB) + unstructured (Qdrant) + relationships (Neo4j) + objects (MinIO)

**Step 4: VEX as Portal**
VEX (vex-site, Vite/TypeScript) becomes the public venture directory. It pulls public data from the infrastructure (Neo4j queries, Postgres views), not from scattered drive folders. Internal data stays in the infrastructure.

**Step 5: Cross-Device Access**
Fix Mac Air SSH (Remote Login on Mac side). Tailscale is already the network layer. Once fixed, all devices can reach the infrastructure and venture files.

## What VEX Should Contain

### Public (on VEX site)

- Venture name
- Tagline / one-line description
- Sector
- Status (live / building / idea / archived)
- Link to live demo or site (if exists)
- Last updated date

### Internal (in infrastructure, not on VEX)

- Financials (revenue, costs, margins)
- Customer lists and CRM data
- Agent specifications and configurations
- Pipeline data (leads, deals, prospects)
- IP and proprietary methods
- Staff and contractor information
- Vendor and partner relationships
- Source code and implementation details

### VEX Data Model

```
VEX_VENTURE (public)
  ├── id: string (e.g. "CON-001")
  ├── name: string
  ├── tagline: string
  ├── sector: string
  ├── status: enum(live, building, idea, archived)
  ├── description: string (1-2 sentences)
  ├── demo_url: string (optional)
  ├── repo_url: string (optional, GitHub)
  ├── updated_at: datetime
  └── source_path: string (T7 or LaCie path, internal)

VEX_SECTOR (public)
  ├── id: string
  ├── name: string
  ├── venture_count: integer
  └── description: string

VEX_STATUS (computed from infrastructure)
  ├── venture_id: string
  ├── has_dashboard: boolean
  ├── has_revenue: boolean
  ├── last_active: datetime
  └── completion_percentage: float (0-100)
```

## Entities and Graphs

The infrastructure should hold multiple graph types:

- **Ontology:** What things are and what they mean (schemas, types, definitions)
- **Topology:** Where systems/devices/services are connected (Tailscale nodes, Docker containers, ports)
- **Lineage:** Where information came from and how it changed (file provenance, edit history)
- **Dependency graph:** What relies on what (venture dependencies, agent dependencies)
- **Organizational graph:** Who owns/manages/executes what (people → ventures → roles)
- **Knowledge graph:** What you know and how you know it (claims, evidence, sources, confidence)
- **Economic graph:** Where money/value moves (ventures → revenue → costs → profit)
- **Ecosystem graph:** How ventures interact with markets and each other (competitive landscape, partnerships, shared resources)

Neo4j holds relationships. Qdrant holds semantic content. Postgres/NocoDB holds structured records. MinIO holds raw objects. The drives remain the source material.

## Next Actions

1. Read the existing `venture_registry.json` (53 ventures with structured metadata) as the seed
2. Perform archaeology across T7 + LaCie to find all ventures not in the registry
3. Generate canonical VENTURE-MASTER-REGISTRY.csv
4. Build ingestion pipeline from existing scripts
5. Connect VEX to infrastructure queries
6. Fix Mac Air SSH
7. Import Obsidian vault into gbrain
