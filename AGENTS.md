# Research OS — Agent Instructions

## Mission

Build and maintain a continuously improving research knowledge system across all ventures, tools, and domains. This is the single source of truth for VEX, Obsidian, Apple Notes, Notebook LM, and all Worldwidebro ventures.

## Core Rule

Never convert an inference into a fact.

## Source of Truth

Research knowledge: /research/
Ontology: /knowledge/ontology/
Schemas: /schemas/
Protocols: /protocols/
Agents: /agents/
Evaluation: /evaluations/

## Integrated Systems

- VEX: Public brand site and venture registry
- Obsidian: Human research interface
- Apple Notes: Mobile capture and quick notes
- Notebook LM: Document analysis and synthesis
- Neo4j: Relationship and reasoning layer
- Qdrant: Semantic retrieval
- PostgreSQL: Structured data
- Git: Version and provenance

## Research Domains

- VEX-CORE: Worldwidebro brand, ventures, ecosystem
- EDU: Education research, learning sciences, pedagogy
- AI-AGENTS: Autonomous agents, memory, planning
- LOGISTICS: Operations and optimization
- All venture domains from repo-index.csv

## Architecture Reference

The full system architecture is documented in `docs/20-SYSTEM-ARCHITECTURE.md`. It covers:

- Infrastructure substrate (21 Docker containers, idle, ready)
- Venture source material distribution (T7 Shield + LaCie)
- The ingestion gap and strategy
- Entity graphs (ontology, topology, lineage, dependency, organizational, knowledge, economic, ecosystem)
- VEX as public portal (pulls from infrastructure, not drives)
- Cross-device access via Tailscale
- Next actions

## VEX Data Model

See `docs/21-VEX-DATA-MODEL.md` for the public vs internal data split, data sources, sync model, and example pages.

## Canonical Venture Registry

The canonical venture dataset lives on T7 Shield:
- `/Volumes/T7 Shield/20_ARCHIVE/20-ventures/consolidated_ventures.json` — 788 ventures, 687 with GitHub repos, already deduplicated (462 duplicates merged)
- `/Volumes/T7 Shield/VENTURE-MASTER-REGISTRY.csv` — canonical CSV extract
- `/Volumes/T7 Shield/VENTURE-MASTER-REGISTRY.json` — canonical JSON extract

## External Reference Repos

These are relevant open-source projects to evaluate for integration:

1. **SonarSource/sonarqube-mcp-server** — Official SonarQube MCP server. Enables AI agents to query code quality and security issues. Docker: `sonarsource/sonarqube-mcp`. Use case: add code quality self-review as an MCP tool for venture repos.

2. **msitarzewski/agency-agents** — 230+ pre-built AI agent personalities across 20+ divisions (engineering, finance, marketing, sales, security, support, etc.). MIT licensed. Native app available. Use case: reference library for agent templates, compare against our custom agents.

3. **anomalyco/opencode** — Open source coding agent (TypeScript, 75.6% TS). Direct competitor to Claude Code/Cursor. 860 releases, 987 contributors. Use case: fallback coding agent if Hermes/Claude unavailable; benchmark for our agent tooling.

4. **openobserve/openobserve** — Rust observability platform (AGPL-3.0). Datadog/Splunk alternative with LLM observability. Single binary, 140x lower storage. Use case: supplement or replace Langfuse for AI observability; consolidate monitoring.

## Integration Status

- **gbrain**: installed at `/Users/divinejohns/bin/gbrain`, brain at `~/.gbrain/brain.pglite`, MCP wired (124 tools). Obsidian vault import pending.
- **Obsidian**: two vaults (~37K + ~14K files). sync scripts exist but not yet run.
- **Apple Notes**: export/triage scripts exist, not yet integrated.
- **NotebookLM**: no local installation or data found.
- **VEX site**: dev server running on port 5173 (PID 88290). Not deployed to Vercel. Live version at vex-hero-site-sigma.vercel.app (has /login, /intake, /admin, /dashboard pages — Vue/Nuxt SPA).
- **Mac Air SSH**: broken — SSH daemon on 100.121.17.63 closes connections. New key generated (`~/.ssh/id_macair`) but needs to be added to Mac Air's authorized_keys. VNC (port 5900) is open as alternative access path.
