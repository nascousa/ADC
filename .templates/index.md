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
- **CGA Relay**: Preferred Context Graph Agent relay profile for programmatic ContextGraph access (default local dev SSE endpoint: `http://localhost:18001/mcp/sse` unless a dedicated relay endpoint is advertised)
- **CGA MCP Server**: Compatibility fallback profile for programmatic ContextGraph access when `cga-relay` is unavailable
- **CGA Relay Profile Standard**: `.adc/contextgraph-edge-agent/mcp/mcp-servers.json` MUST include a `cga-relay` entry before `cga-mcp-server` so ADC-based projects prefer CGA relay wiring while retaining the MCP server fallback.
- **Initial ContextGraph Indexing**: Immediately after ContextGraph Edge Agent + CGA relay integration, run full-project indexing once so retrieval/review tools can access the entire repository context.

ContextGraph MCP access is endpoint-first by default. A local MCP implementation is optional and repository-specific.

## Environment Requirements
Refer to `bootstrap.md` for exact start-up commands.


