# Research OS — Claude Code Context

## Mission

Build and maintain a continuously improving research knowledge system across all ventures, tools, and domains. This is the single source of truth for VEX, Obsidian, Apple Notes, Notebook LM, and all Worldwidebro ventures.

## Core Rule

Never convert an inference into a fact.

## Source of Truth

- Research knowledge: `/research/`
- Ontology: `/knowledge/ontology/`
- Schemas: `/schemas/`
- Protocols: `/protocols/`
- Agents: `/agents/`
- Evaluation: `/evaluations/`
- Architecture: `/docs/20-SYSTEM-ARCHITECTURE.md`
- VEX data model: `/docs/21-VEX-DATA-MODEL.md`

## Canonical Venture Data

The canonical venture dataset is on T7 Shield:
- `consolidated_ventures.json` (788 ventures, 687 with GitHub repos)
- `VENTURE-MASTER-REGISTRY.csv` (canonical deduplicated registry)
- `VENTURE-MASTER-REGISTRY.json` (canonical JSON extract)

## Infrastructure (idle, ready)

- Neo4j: localhost:7474 / 7687
- Qdrant: localhost:6333
- MinIO: localhost:9000 / 9001
- Postgres CRM: localhost:5434
- Postgres secondary: localhost:5433
- n8n: localhost:5678
- Twenty CRM: localhost:3004
- Langfuse: localhost:3003
- MCPJungle: localhost:8787
- Redis: localhost:6379 / 6380
- Datasette: localhost:8001 (repos-analysis.db)
- gbrain MCP: 124 tools available

## External Reference Projects

- SonarSource/sonarqube-mcp-server — code quality MCP for agents
- msitarzewski/agency-agents — 230+ agent templates
- anomalyco/opencode — open source coding agent
- openobserve/openobserve — observability + LLM observability

## Integration Status

- gbrain: installed, MCP-wired, brain initialized
- Obsidian sync: scripts exist, not yet run
- Mac Air SSH: broken (key generated, needs to be placed on Mac Air)
- VEX: dev on 5173, not on Vercel
