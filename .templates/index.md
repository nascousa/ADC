---
project-name: "Agentic Boilerplate Project"
version: "1.0.0"
description: "A reference implementation of the Autonomous Development Constitution (ADC)."
tech-stack:
  - React 18
  - Node.js 20
  - PostgreSQL
architecture-style: "Microservices"
entry-points:
  - src/main.ts
---

# Project Overview
This project serves as a reference implementation of the ADC standard. 
It defines the exact rules, constraints, and architecture that AI Agents must follow.

## Core Modules
- `src/api`: Core backend services
- `src/web`: Frontend React application
- `src/contextgraph-edge-agent`: ContextGraph Edge Agent (local execution and orchestration)

## Required Integrations
This project **MUST** integrate with the ContextGraph ecosystem:
- **ContextGraph Project**: Central repository and artifact management system (registration via Context Graph Agent (CGA) Admin UI at `http://localhost:18001/admin`)
- **ContextGraph Edge Agent** (`src/contextgraph-edge-agent`): Local execution and orchestration agent
- **CGA Relay**: Mandatory Context Graph Agent profile and required path for ContextGraph indexing plus all project change information aggregation (default local dev SSE endpoint: `http://localhost:18001/mcp/sse` unless a dedicated relay endpoint is advertised)
- **CGA MCP Server**: Compatibility fallback profile for non-indexing programmatic ContextGraph access when `cga-relay` is unavailable
- **CGA Relay Profile Standard**: `.adc/contextgraph-edge-agent/mcp/mcp-servers.json` MUST include a `cga-relay` entry before `cga-mcp-server` so ADC-based projects enforce CGA relay-first wiring while retaining the MCP server fallback.
- **CGA Relay-First Execution Policy**: All ContextGraph MCP retrieval, progress-reporting, and integration operations MUST attempt `cga-relay` first. `cga-mcp-server` MAY be used for non-indexing compatibility only after relay is unavailable, and the fallback reason MUST be documented in task or validation notes.
- **Mandatory CGA-Relay Indexing**: All ADC-compliant projects MUST complete ContextGraph indexing through `cga-relay`; `cga-mcp-server` fallback MAY document relay unavailability but MUST NOT count as successful indexing completion.
- **Mandatory CGA-Relay Change Aggregation**: All ADC-compliant projects MUST aggregate change summaries, indexing metadata, progress updates, validation evidence, release events, blockers, risks, and PR/PBI metadata into CGA through `cga-relay`; direct API or fallback MCP writes do not count as official completion.
- **Initial ContextGraph Indexing**: Immediately after ContextGraph Edge Agent + CGA relay integration, run full-project indexing through `cga-relay` once so retrieval/review tools can access the entire repository context.

ContextGraph MCP access is endpoint-first by default. A local MCP implementation is optional and repository-specific.

## Environment Requirements
Refer to `bootstrap.md` for exact start-up commands.


