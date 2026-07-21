$TargetDir = "d:\Repos\ARKSOFT\PCS\adc-template"

Write-Host "Generating ADC template at $TargetDir ..."
New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\standards\conventions" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\standards\checklists" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\standards\runbooks" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\skills\sample-skill\scripts" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\adr" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\tasks\done" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\tasks\in-progress" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\tasks\todo" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\scratchpad" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\mcp" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\skills\sample-skill\scripts" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\tasks\done" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\tasks\in-progress" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\tasks\todo" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\scratchpad" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\mcp" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\contextgraph-edge-agent\skills\sample-skill\scripts" | Out-Null

$Files = @{
    "index.md" = @'
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

## Required Integrations
This project **MUST** integrate with the ContextGraph ecosystem:
- **ContextGraph Project**: Central repository and artifact management system (registration via Context Graph Agent (CGA) Admin UI at `http://localhost:18001/admin`)
- **ContextGraph Edge Agent** (`src/contextgraph-edge-agent`): Local execution and orchestration agent
- **CGA Relay**: Mandatory Context Graph Agent profile and required path for ContextGraph indexing plus all project change information aggregation (default local dev SSE endpoint: `http://localhost:18001/mcp/sse` unless a dedicated relay endpoint is advertised)
- **CGA MCP Server**: Compatibility fallback profile for non-indexing programmatic ContextGraph access when `cga-relay` is unavailable
- **CGA Relay Profile Standard**: `.adc/contextgraph-edge-agent/mcp/mcp-servers.json` MUST include a `cga-relay` entry before `cga-mcp-server` so ADC-based projects enforce CGA relay-first wiring while retaining the MCP server fallback.
- **Local CGA-Relay Executable Priority**: For project status synchronization, agents MUST prefer the local CGA-Relay release executable when available (standard Windows path: `D:\Repos\ContextGraphAdmin\src\cga-relay\target\release\cga-relay.exe`, or `CGA_RELAY_EXE` when configured) and run `sync --config %USERPROFILE%\.cga\agent.env --namespace account --project-tag <project_tag>` before trying MCP profile or fallback paths.
- **CGA Relay-First Execution Policy**: All ContextGraph MCP retrieval, progress-reporting, and integration operations MUST attempt `cga-relay` first. `cga-mcp-server` MAY be used for non-indexing compatibility only after relay is unavailable, and the fallback reason MUST be documented in task or validation notes.
- **Mandatory CGA-Relay Indexing**: All ADC-compliant projects MUST complete ContextGraph indexing through `cga-relay`; `cga-mcp-server` fallback MAY document relay unavailability but MUST NOT count as successful indexing completion.
- **Mandatory CGA-Relay Change Aggregation**: All ADC-compliant projects MUST aggregate change summaries, indexing metadata, progress updates, validation evidence, release events, blockers, risks, and PR/PBI metadata into CGA through `cga-relay`; direct API or fallback MCP writes do not count as official completion.
- **Initial ContextGraph Indexing**: Immediately after ContextGraph Edge Agent + CGA relay integration, run full-project indexing through `cga-relay` once so retrieval/review tools can access the entire repository context.

ContextGraph MCP access is endpoint-first by default. A local MCP implementation is optional and repository-specific.

## Environment Requirements
Refer to `bootstrap.md` for exact start-up commands.
'@;

    "bootstrap.md" = @'
# Environment Bootstrap Guide

Follow these exact steps to start the application locally from scratch.
Never attempt to guess the start commands.

## ContextGraph Services Integration

Before starting the application, register with the ContextGraph ecosystem:

```bash
# 1. Register this project with ContextGraph
# Open Context Graph Agent (CGA) Admin UI: http://localhost:18001/admin
# Follow the guided setup to:
#   - Register this project in the ContextGraph catalog
#   - Retrieve Context Graph Agent (CGA) relay/MCP credentials and edge agent token
#   - Store credentials in .env (see step 2 below)

# 2. Configure ContextGraph environment variables
echo "CONTEXTGRAPH_MCP_SERVER_URL=http://localhost:18001/mcp/sse" >> .env
echo "CONTEXTGRAPH_RELAY_URL=http://localhost:18001/mcp/sse" >> .env
echo "CONTEXTGRAPH_INDEXING_POLICY=auto-incremental" >> .env
echo "CONTEXTGRAPH_EDGE_AGENT_TOKEN=<token-from-cga-admin>" >> .env
echo "CONTEXTGRAPH_PROJECT_ID=<project-id-from-cga-admin>" >> .env
```

After ContextGraph Edge Agent and CGA relay are integrated, initialize a full repository index before starting feature work:

```text
Required one-time bootstrap indexing flow
1) Ensure `mcp-servers.json` contains the `cga-relay` endpoint profile before `cga-mcp-server`, and both profiles receive project context from environment variables.
2) Run a full-project indexing call through `cga-relay` using:
   - project_id: CONTEXTGRAPH_PROJECT_ID
   - repo_path: repository root
   - changed_files: all tracked source and documentation files
3) Treat indexing as successful only after `cga-relay` and the ContextGraph service return a successful completion status.
4) Treat `cga-relay` as the mandatory and only official MCP profile for indexing and project change information aggregation, and as the mandatory first-attempt MCP profile for retrieval and other ContextGraph integration calls.
5) Configure relay-routed work briefing reports for service starts, feature milestones, validation runs, releases, blockers, risks, and PR/PBI metadata.
```

For all later changes, MUST run `index_repo_changes(repo_path)` through `cga-relay`, so modified source, documentation, configuration, and test content is indexed automatically through the required relay path. Also publish a compact change summary, validation/progress event, and relevant PR/PBI metadata through `cga-relay` so CGA receives the full change record. If relay is unavailable, record blocked change aggregation and retry; do not count direct API or `cga-mcp-server` fallback as official completion.

For project status synchronization, prefer the local CGA-Relay release executable before MCP profile or fallback paths. Use `CGA_RELAY_EXE` when configured; otherwise, on the standard Windows CGA workstation, use `D:\Repos\ContextGraphAdmin\src\cga-relay\target\release\cga-relay.exe`:

```powershell
$relayExe = if ($env:CGA_RELAY_EXE) { $env:CGA_RELAY_EXE } else { "D:\Repos\ContextGraphAdmin\src\cga-relay\target\release\cga-relay.exe" }
& $relayExe sync --config "$env:USERPROFILE\.cga\agent.env" --namespace account --project-tag "<project_tag>"
```

If the executable is missing or sync fails due to authentication or connectivity, record blocked change aggregation in `.adc/contextgraph-edge-agent/scratchpad/session.md`, refresh relay login/configuration, and retry. Do not count direct CGA API calls or `cga-mcp-server` writes as official project status synchronization.

## Auto-Enable CGA Relay Profile (ADC Standard)

ADC-compliant projects must keep the `cga-relay` profile enabled before the fallback `cga-mcp-server` profile in `.adc/contextgraph-edge-agent/mcp/mcp-servers.json`. All official ContextGraph indexing and change information aggregation must use `cga-relay`; fallback profiles may document relay outages but must not satisfy indexing or change reporting completion.

```text
Quick enable checklist for downstream projects
1) Copy the ADC template `.adc/contextgraph-edge-agent/mcp/mcp-servers.json` into the target project.
2) Confirm `cga-relay` exists before `cga-mcp-server` and points to a reachable CGA relay/MCP SSE endpoint (default local dev endpoint: `http://localhost:18001/mcp/sse`).
3) Set environment variables before starting your IDE/agent host:
    - CONTEXTGRAPH_MCP_TOKEN
    - CONTEXTGRAPH_EDGE_AGENT_TOKEN
    - CONTEXTGRAPH_PROJECT_ID
    - CONTEXTGRAPH_RELAY_URL, when the deployment advertises a dedicated relay endpoint
4) Import the MCP file in your AI client so the server profile is loaded automatically.
5) Run one full-project index once, then switch to incremental indexing on changed files.
6) Confirm project change reporting flows through `cga-relay` to CGA without logging raw tokens.
```

## Local Development Setup

```bash
# 3. Install dependencies
npm install

# 4. Setup the environment configuration
cp .env.example .env
# (Edit .env with values from ContextGraph registration above)

# 5. Start ContextGraph services (if this repository includes local implementations)
npm run contextgraph-mcp:start      # Optional local MCP bridge for repos that ship one
npm run contextgraph-edge:start     # Starts src/contextgraph-edge-agent service (default: http://localhost:3002/edges)

# 6. Start backing services (e.g. database, redis)
docker-compose up -d db redis

# 7. Run database migrations
npm run db:migrate

# 8. Start the local development server
npm run dev
```

## Verify ContextGraph Connectivity

Once running, verify local ContextGraph services are reachable:

```bash
# Check local MCP server health (src/contextgraph-mcp)
curl http://localhost:3001/mcp/health

# Check local edge agent health (src/contextgraph-edge-agent)
curl http://localhost:3002/edges/health

# Verify ContextGraph local dev API connectivity
curl http://localhost:18001/health
```
'@;

    "prompt-rules.md" = @'
# AI Prompt Rules

## Mandatory Core Rules
- Use absolute paths when importing modules.
- For every ADC update, increment README version and update README date in the same change.
- Do not bypass safety checks in `.adc/standards/conventions/security.md`.
- All project communications MUST follow the PQC/CNSA 2.0 baseline in `.adc/standards/conventions/security.md`.
- Follow Test-Driven Development (TDD) in `.adc/standards/conventions/testing.md`.
- Before external community participation or project promotion, read and follow `.adc/standards/conventions/external-engagement.md`; all four thread-selection gates MUST pass before engaging with a current or possible future promotion objective.
- For web page design/debug tasks, use the built-in browser shared page as the default validation surface before considering external browser automation.
- Default web applications should use FastAPI, PostgreSQL with `pgvector`, dark mode, and the login background pattern defined in `.adc/standards/conventions/frontend.md`.
- Do not introduce new third-party dependencies (for example, `npm install`, `pip install`) without explicit human authorization.
- Document progress, failed attempts, and environment issues in `.adc/contextgraph-edge-agent/scratchpad/session.md` before concluding a task.
- Keep outputs deterministic for the same symbol and unchanged repository state.

## Repository and Workflow Rules
- For new features, write tests first.
- Keep source logic in `src/`, scripts in `src/scripts/`, tests in `tests/`, and docs in `docs/`.
- Do not commit secrets, tokens, or private keys.
- All Docker commands must use remote daemon `tcp://192.168.1.239:2375` via `DOCKER_HOST`.
- Never commit directly to `main`; use a `dev/*` branch and merge through review.

## ContextGraph Use Policy
- Use `contextgraph-edge-agent/` for local task orchestration and session context only.
- Use `mcp-servers.json` and ContextGraph MCP endpoints for indexed retrieval/integration workflows only.
- Ensure `.adc/contextgraph-edge-agent/mcp/mcp-servers.json` MUST contain `cga-relay` before `cga-mcp-server`, with `cga-relay` enabled as the mandatory ContextGraph indexing and change aggregation path while `cga-mcp-server` is retained only as non-indexing fallback for ADC-compliant repositories.
- Register every project in Context Graph Agent (CGA) and MUST automatically install or refresh the paired `cga-relay` profile before substantial feature work.
- For project status synchronization, MUST use the local CGA-Relay release executable first when available (`CGA_RELAY_EXE` or `D:\Repos\ContextGraphAdmin\src\cga-relay\target\release\cga-relay.exe`) with `sync --config %USERPROFILE%\.cga\agent.env --namespace account --project-tag <project_tag>` before MCP profile or fallback paths.
- Report all meaningful project change information to CGA through `cga-relay`, including change summaries, progress, validation evidence, release events, blockers, risks, and PR/PBI metadata. Also MUST run `index_repo_changes(repo_path)` through `cga-relay` after meaningful source, documentation, configuration, or test changes; if relay is unavailable, record blocked change aggregation and retry rather than counting direct API or `cga-mcp-server` fallback as successful completion.
- Do not assume a Node-specific local MCP bootstrap; prefer endpoint-first MCP profiles and keep integration language/runtime-agnostic unless the repository explicitly provides a local server implementation.
- ContextGraph MCP must not replace local compile, lint, unit test, or integration test execution.
- Treat scratchpad/task outputs as operational context, not canonical product truth.
- Canonical rules must remain in `.adc/planning/`, `.adc/standards/`, and `.adc/knowledge/`.
- Inject `CONTEXTGRAPH_MCP_TOKEN`, `CONTEXTGRAPH_EDGE_AGENT_TOKEN`, and `CONTEXTGRAPH_PROJECT_ID` via environment variables only.
- Never write ContextGraph credentials into tracked files.
- PRs changing ContextGraph integration behavior must update `.adc/bootstrap.md` and MCP server wiring, and include validation notes.

## ContextGraph Retrieval and Token Policy
- For non-trivial coding tasks, perform ContextGraph retrieval before editing files.
- Prefer FalkorDB Cypher traversal over Python loops for impact graph search.
- Required pre-edit sequence: `contextgraph_index_incremental` -> `contextgraph_query_impact_graph` -> `get_optimized_context` -> `contextgraph_fetch_minimal_code`.
- Use incremental indexing for changed files through `cga-relay`; avoid full reindex for routine tasks.
- Retrieve context in order: impact graph -> optimized context -> minimal code.
- Use symbol-scoped or change-scoped queries; avoid whole-repository prompts.
- Start with conservative budgets (`800-1500`) and expand only when evidence is insufficient.
- Apply explicit `token_budget` limits and keep only direct dependencies, recent changes, and high-frequency call paths.
- Reuse previously selected minimal context across related follow-up questions instead of re-fetching broad context.
- If ContextGraph evidence is missing, report missing symbols/files first, then run one bounded fallback search.
- Keep answers evidence-first by citing minimal retrieved code context before proposing broad refactors.

## ContextGraph-First Trigger Conditions
- Cross-module changes.
- Noisy repository search or ambiguous ownership.
- Runtime errors where call chain/source owner is unclear.
- Requests expected to exceed a small context window.

## Allowed Exceptions
- Single-line edits with exact file and line already known.
- Pure formatting or comment-only updates.
- Emergency hotfixes where retrieval failure blocks immediate mitigation.
'@;

    "conventions\devops.md" = @'
# DevOps Workflow Policy

## Branching and Check-In Rules
- **No Direct Check-In to `main`**: Direct commits or direct pushes to the `main` branch are forbidden.
- **Required Development Branch**: All code check-ins MUST be performed on a dedicated development branch named `dev/<scope>` (or `dev/<scope>-<ticket>`).
- **Merge Path**: Changes MUST be merged into `main` only through a reviewed Pull Request.
- **Pre-Merge Gates**: Required CI checks and policy checklist validation MUST pass before merge.
- **Hotfix Exception**: Emergency hotfixes may use `hotfix/<scope>` branches, but direct commits to `main` are still forbidden.

## Deploy Key Handling Policy
- **Documentation Location**: The active public deploy key MUST be recorded in `docs/deploy_key.md`.
- **Preferred Source**: Reuse an existing approved public deploy key when available.
- **Fallback Generation**: If no approved deploy key exists, generate a new SSH key pair without passphrase and record the public key in `docs/deploy_key.md`.
- **No Private Key in Repo**: Private keys MUST NEVER be committed to the repository.
- **Rotation Update**: When deploy keys rotate, `docs/deploy_key.md` MUST be updated in the same change set.

## ContextGraph Integration Policy
- **Authoritative Onboarding URL**: Integration with ContextGraph MUST use the Context Graph Agent (CGA) Admin UI at `http://localhost:18001/admin` as the local setup surface for project registration and token creation.
- **Mandatory Registration**: All ADC-compliant projects MUST be registered in Context Graph Agent (CGA) before feature work begins unless CGA is temporarily unavailable and the exception is documented.
- **Automatic Relay Installation**: Project bootstrap MUST automatically install or refresh the paired `cga-relay` profile before the fallback `cga-mcp-server` profile in `.adc/contextgraph-edge-agent/mcp/mcp-servers.json` using environment-variable backed credentials.
- **No Unreviewed Deviation**: Agents and developers MUST NOT use alternate ContextGraph onboarding flows unless explicitly approved in the same PR description.
- **Traceability Requirement**: Any PR that introduces or changes ContextGraph integration MUST include a short "ContextGraph integration notes" section describing what step(s) from the onboarding URL were applied.
- **MCP Alignment**: If ContextGraph integration adds or changes external service endpoints or credentials, `mcp-servers.json` MUST be updated in the same change set.

## ContextGraph Edge Agent and ContextGraph MCP Use Policy
- **Responsibility Split**: `contextgraph-edge-agent/` is for local orchestration artifacts (task queues, scratchpad notes, MCP wiring). ContextGraph MCP is for programmatic integration/retrieval against ContextGraph services.
- **CGA Relay Profile Baseline**: ADC templates MUST ship a `cga-relay` entry before `cga-mcp-server` in `.adc/contextgraph-edge-agent/mcp/mcp-servers.json` so downstream repositories auto-inherit mandatory relay-first CGA wiring with MCP server fallback.
- **Local CGA-Relay Executable Priority**: For project status synchronization, agents MUST use the local CGA-Relay release executable first when available (`CGA_RELAY_EXE` or the standard Windows path `D:\Repos\ContextGraphAdmin\src\cga-relay\target\release\cga-relay.exe`). The required command shape is `sync --config %USERPROFILE%\.cga\agent.env --namespace account --project-tag <project_tag>`.
- **Relay-First Execution Policy**: All ContextGraph MCP retrieval, progress-reporting, and integration operations MUST attempt `cga-relay` first. `cga-mcp-server` MAY be used for non-indexing compatibility only after relay is unavailable, and the fallback reason MUST be documented in task or validation notes.
- **Mandatory CGA-Relay Indexing**: All ADC-compliant projects MUST complete ContextGraph indexing through `cga-relay`, including initial full-project indexing, incremental indexing, and `index_repo_changes(repo_path)`. `cga-mcp-server` fallback MAY document a relay outage, but it MUST NOT be treated as successful indexing completion.
- **Mandatory CGA-Relay Change Aggregation**: All ADC-compliant projects MUST aggregate project change information into CGA through `cga-relay`, including change summaries, modified-file indexing metadata, progress updates, validation evidence, release events, blockers, risks, and PR/PBI metadata. Direct CGA API writes or fallback MCP writes MAY document relay outages, but they MUST NOT be treated as official change reporting completion.
- **Runtime Neutrality**: MCP wiring MUST be language-agnostic by default. Do not require a Node-specific local entrypoint unless that repository explicitly ships and maintains one.
- **Execution Policy**: ContextGraph MCP MUST NOT be used to replace local compile, lint, unit test, or integration test execution. Build/test must run through project-native tooling.
- **Authority Policy**: Outputs from ContextGraph Edge Agent scratchpad/tasks are operational context, not product truth. Canonical product rules remain in constitution/convention/planning files.
- **Network Policy**: Local ContextGraph services are expected on localhost endpoints; upstream ContextGraph access MUST use the configured upstream URL and approved credentials only.
- **Default Relay Endpoint**: Local dev MCP clients MUST route `cga-relay` to `http://localhost:18001/mcp/sse` unless the CGA deployment explicitly advertises a different relay or MCP SSE endpoint.
- **Secret Policy**: Tokens and project identifiers (`CONTEXTGRAPH_MCP_TOKEN`, `CONTEXTGRAPH_EDGE_AGENT_TOKEN`, `CONTEXTGRAPH_PROJECT_ID`) MUST be injected via environment variables and never committed to repository files.
- **Change Policy**: Any PR changing ContextGraph integration behavior MUST update both `bootstrap.md` and `mcp-servers.json`, and include validation notes.

## CGA Change Aggregation, Progress Reporting, and Indexing Policy
- **Automatic Progress Reporting**: Projects MUST emit progress and change reports to CGA through `cga-relay`, using `workassist_record_activity` or the relay-approved change reporting tool for service starts, template generation, feature milestones, validation runs, releases, blockers, risks, and PR/PBI metadata.
- **Project Status Sync**: After meaningful project changes, agents MUST attempt local executable sync before MCP fallback paths: `cga-relay.exe sync --config %USERPROFILE%\.cga\agent.env --namespace account --project-tag <project_tag>`. If sync fails due to authentication or connectivity, record the blocker and retry after relay login/configuration is refreshed.
- **Change Indexing**: After meaningful source, documentation, configuration, or test changes, agents MUST run `index_repo_changes(repo_path)` through `cga-relay`, so CGA indexes modified content through the required relay path.
- **Periodic Indexing**: Long-running projects SHOULD schedule periodic incremental indexing even when no single task explicitly requests it, so CGA remains current.
- **Failure Handling**: If `cga-relay` change aggregation or indexing is unavailable, continue local build/test validation, record the blocked change aggregation in `.adc/contextgraph-edge-agent/scratchpad/session.md`, and retry when CGA is reachable. Do not mark change reporting or indexing complete through direct API or `cga-mcp-server` fallback.
'@;

    "conventions\frontend.md" = @'
# Frontend Application Policy

## Default Web App Experience
- **Dark Mode Default**: All web application projects MUST default to dark mode unless the product owner explicitly approves another theme. Light mode may exist as an option, but the first-run experience should be dark.
- **Admin UI Baseline**: Dashboard/admin surfaces SHOULD use the layout density, navigation rhythm, and component proportions of `https://admin-demo.vuestic.dev` as the default visual reference.
- **Login Background Default**: Login pages SHOULD use a Vanta.js net-style background with white dots/lines at 15% opacity. If Vanta.js cannot be loaded safely, provide a static CSS fallback that preserves the same white net-on-dark visual intent.
- **Accessible Contrast**: Dark mode colors MUST meet WCAG AA contrast for text and controls. Do not rely on opacity-only text for primary labels or actionable controls.

## Browser Debugging Policy
- **Built-In Browser First**: For all projects that design or modify web pages, agents MUST use the built-in browser shared page as the default debugging and self-validation surface.
- **Self-Debug Requirement**: Before concluding frontend work, agents SHOULD load the changed page in the built-in browser shared page, inspect visible layout/state, and capture console or network errors when available.
- **BrowserAgent Exception**: Use the BrowserAgent (BA) project plus browser extension only for special cases that require extension APIs, browser-permission flows, cross-browser behavior, or automation unavailable in the built-in browser shared page.
- **Evidence Discipline**: Frontend validation notes SHOULD state which page was opened, what viewport/state was checked, and whether console/runtime errors were observed.

## Default Frontend Integration
- **FastAPI Pairing**: New web apps SHOULD assume a FastAPI backend unless the target platform explicitly requires another API framework.
- **pgvector-Aware UX**: Search, recommendation, semantic retrieval, or AI-assist UI flows SHOULD be designed with PostgreSQL `pgvector` as the default vector persistence layer.
'@;

    "conventions\backend.md" = @'
# Backend Application Policy

## Default API Runtime
- **FastAPI Default**: New web application backends SHOULD use FastAPI as the default API framework unless project requirements explicitly justify another runtime.
- **Typed Contracts**: FastAPI request and response models MUST use explicit Pydantic schemas for externally visible API contracts.
- **Health Endpoint**: FastAPI services MUST expose a lightweight `/health` endpoint suitable for Docker Compose health checks and local smoke validation.
- **Async Boundaries**: Use async handlers for I/O-heavy endpoints and keep blocking CPU-heavy work outside request handlers unless explicitly bounded.

## Default Web App Data Pairing
- **PostgreSQL Default**: New web application backends SHOULD use PostgreSQL as the default relational database.
- **pgvector Default**: If the application includes semantic search, recommendations, embeddings, RAG, or AI-assisted retrieval, PostgreSQL with `pgvector` is the default vector store.
- **Migration Discipline**: Schema changes MUST be expressed through repeatable migrations and include rollback or forward-fix notes.
'@;

    "conventions\data-engineering.md" = @'
# Data Engineering Policy

## PostgreSQL Vector Policy (`pgvector`)
- **Standard Vector Store**: For production semantic search, PostgreSQL with `pgvector` is the default vector persistence layer.
- **Default Web App Store**: Web application projects SHOULD default to PostgreSQL plus `pgvector` when they need relational data and vector retrieval in the same product surface.
- **Model Consistency**: Each embedding column MUST be tied to a single embedding model/version and fixed vector dimension.
- **Index Strategy**: Use `HNSW` or `IVFFlat` indexes for vector columns based on latency/recall requirements. Brute-force scans are not allowed for production-scale datasets.
- **Query Constraints**: All vector queries MUST enforce explicit `top_k` limits and include metadata filters when available.
- **Distance Metric Discipline**: Use a single declared similarity metric per index/query path (cosine, inner product, or L2) and do not mix metrics in the same retrieval pipeline.

## SQLite Vector Policy (`sqlite-vec`)
- **Scope**: `sqlite-vec` is allowed for local development, offline testing, and lightweight edge use cases.
- **Production Guardrail**: Do not use `sqlite-vec` as the primary retrieval backend for high-concurrency production workloads unless explicitly approved by architecture review.
- **Migration Readiness**: Local vector schema and retrieval contract MUST be compatible with planned migration to `pgvector`.

## Graph Database Policy
- **When to Use Graph DB**: Use graph databases for deep relationship traversal, variable-depth path queries, and graph-native analytics.
- **Query Interface**: Graph workloads MUST use the official graph connector and graph query language (Cypher/Gremlin) rather than recursive SQL workarounds.
- **Identity Consistency**: Node/edge identifiers MUST be stable and map cleanly to relational primary keys where dual storage exists.
- **Write Safety**: Graph mutation paths MUST be idempotent and support retry-safe behavior for at-least-once delivery.

## Cross-Store Data Governance
- **Ownership Rule**: For each entity, define a single source of truth (relational, vector, or graph) and document replication/sync direction.
- **Backfill Rule**: Any re-embedding or graph backfill process MUST be versioned, resumable, and observable.
- **Deletion Rule**: Data deletion requests MUST propagate consistently across relational, vector, cache, and graph stores.
'@;

    "known-issues.md" = @'
# Technical Debt & No-Touch Zones
- `src/legacy-billing/`: **DO NOT TOUCH**. This is a fragile legacy sub-system. Only modify if explicitly instructed by human to fix a critical P0 bug.
- The `AuthService` class currently has tight coupling with the Redis cache. Do not attempt to refactor this class without explicit permission.
'@;

    "amendments.md" = @'
# Constitutional Amendments
*All changes to the rules inside the `.adc` directory MUST be proposed via PR with the `[AMENDMENT]` prefix. It MUST NOT be modified autonomously without human ratification.*

- **2026-03-13**: Digital Constitution initial ratification. V1.0.0 created.
- **2026-05-26**: Standardized the ADC MCP profile name to `cga-mcp-server`, set the default local dev SSE endpoint to `http://localhost:18001/mcp/sse`, and required Authorization/X-Project-ID headers in the standard profile.
- **2026-05-26**: Added default web-app standards for built-in browser shared-page debugging, FastAPI, PostgreSQL `pgvector`, dark mode, Vanta.js login backgrounds, CGA progress reporting, and automatic change indexing.
- **2026-06-04**: Added the mandatory PQC/CNSA 2.0 communication baseline requiring ML-KEM/ML-DSA or approved CNSA 2.0 PQC successors for all project communication paths.
- **2026-06-10**: Added `cga-relay` as the preferred CGA MCP profile before `cga-mcp-server`, retained `cga-mcp-server` as fallback, and standardized the expanded name to Context Graph Agent (CGA).
- **2026-06-12**: Elevated CGA relay precedence to a mandatory relay-first policy for ContextGraph MCP operations before `cga-mcp-server`, with fallback reasons documented; the 2026-06-15 amendment supersedes indexing fallback behavior.
- **2026-06-15**: Strengthened ADC indexing governance so all ADC-compliant projects MUST complete initial, incremental, and change indexing through `cga-relay`; `cga-mcp-server` fallback can document relay outages but does not count as official indexing completion.
- **2026-06-15**: Broadened CGA relay governance so all ADC-compliant projects MUST aggregate any meaningful project change information into CGA through `cga-relay`, including change summaries, indexing metadata, progress, validation, release, blocker, risk, and PR/PBI events.
- **2026-07-01**: Added local CGA-Relay executable priority for project status synchronization. When the release executable is available, agents MUST run `sync --config %USERPROFILE%\.cga\agent.env --namespace account --project-tag <project_tag>` before MCP profile or fallback paths.
- **2026-07-21**: Added a project-neutral external engagement and promotion convention with mandatory four-gate thread selection, discussion-first participation, transparent affiliation disclosure, evidence-backed claims, link limits, natural pacing, and anti-spam safeguards.
'@;

    "conventions\security.md" = @'
# Security & Vulnerability Management
- **Inviolable Rule**: Do NOT introduce dependencies with a CVSS score >= 7.0.
- **Input Sanitization**: All external inputs MUST run through the Zod validation middleware before reaching controllers.
- **Secret Management**: NEVER hardcode API keys. All keys MUST be retrieved at runtime via `aws-secrets-manager`.

## Post-Quantum Communications Standard (PQC/CNSA 2.0)
- **Mandatory Scope**: All project communication paths MUST use CNSA 2.0-aligned post-quantum cryptography, including public APIs, service-to-service calls, admin surfaces, database/cache/message-broker connections, MCP endpoints, webhooks, CI/CD callbacks, telemetry export, replication, backup transfer, and agent-to-service communication.
- **Approved Key Establishment**: Key establishment MUST use ML-KEM (NIST FIPS 203 / CRYSTALS-Kyber lineage) or a CNSA 2.0-approved PQC successor at the required CNSA 2.0 strength level. When a stack exposes parameter sets, default to ML-KEM-1024 unless a project security profile explicitly approves another CNSA 2.0-compliant level.
- **Approved Digital Signatures**: Digital signatures for certificates, software artifacts, protocol handshakes, webhook signing, release signing, and machine-to-machine trust MUST use ML-DSA (NIST FIPS 204 / CRYSTALS-Dilithium lineage) or a CNSA 2.0-approved PQC successor. When a stack exposes parameter sets, default to ML-DSA-87 unless a project security profile explicitly approves another CNSA 2.0-compliant level.
- **Transport Requirement**: Use PQC-capable TLS, mTLS, SSH, VPN, message-bus encryption, or protocol-native protection that negotiates approved ML-KEM/ML-DSA or hybrid PQC suites. Legacy-only TLS, plaintext HTTP, unsigned webhooks, unauthenticated broker links, and non-PQC tunnels are forbidden for project communications.
- **Hybrid Transition Rule**: If production infrastructure cannot yet negotiate pure PQC suites, use hybrid classical plus PQC negotiation, document the limitation, add a migration owner and expiry date, and keep the channel on the CNSA 2.0 transition path.
- **Evidence Requirement**: PRs that add or change communication paths MUST include evidence of the negotiated KEM/signature suite, library or platform configuration, and any approved exception. Missing evidence blocks merge.
- **Exception Policy**: Exceptions require explicit human approval through the constitutional amendment process, a named owner, compensating controls, and a time-bounded expiry date enforced in review.

## Common Security Strategies
- **Least Privilege Access**: Grant users, services, and CI jobs only the minimum permissions required, and review privileges regularly.
- **Defense in Depth**: Apply layered controls across application, infrastructure, and network boundaries so one control failure does not expose critical assets.
- **Secure by Default Configuration**: Default new services to deny-all network posture, strict auth requirements, and disabled debug/admin surfaces.
- **Strong Authentication and Authorization**: Enforce strong identity verification, short-lived credentials, and explicit authorization checks on every protected action.
- **Encryption in Transit and at Rest**: Require CNSA 2.0-aligned PQC-capable protection for all external and internal service communication and encrypt sensitive persisted data with managed keys.
- **Input Validation and Output Encoding**: Validate all untrusted input against strict schemas and encode output contexts to prevent injection vulnerabilities.
- **Dependency and Supply Chain Security**: Pin dependencies, run vulnerability scans in CI, verify package integrity, and remove unused packages.
- **Secret Lifecycle Management**: Store secrets in dedicated secret managers, rotate on schedule, and revoke immediately on exposure suspicion.
- **Secure Logging and Monitoring**: Use structured logs without sensitive payloads, alert on anomalous auth/access patterns, and preserve audit trails.
- **Patch and Vulnerability Management**: Apply security updates quickly, track temporary exceptions with expiry, and require owner accountability.
- **Incident Response Readiness**: Maintain runbooks for detection, containment, recovery, and post-incident review with assigned responders.
- **Backup and Recovery Validation**: Protect backups with encryption and test restore procedures regularly to ensure recovery objectives are achievable.

## Version, Update, and Patch Security Strategies
- **Security-First Versioning**: Treat security fixes as highest-priority releases and publish versioned patch notes with risk and remediation context.
- **Patch Cadence Policy**: Apply routine dependency and base-image updates on a fixed schedule, with emergency out-of-band patches for critical vulnerabilities.
- **Risk-Based Prioritization**: Prioritize updates by exploitability and asset exposure, not only by CVSS score.
- **Time-Bounded Exceptions**: Any temporary vulnerability exception MUST include owner, justification, and explicit expiry date enforced in CI.
- **Canary and Rollback Safety**: Roll out sensitive security updates in stages and maintain tested rollback paths for failed deployments.
- **Compatibility and Regression Gates**: Security-related upgrades MUST pass automated tests, policy checks, and smoke validation before merge.
- **Provenance and Integrity Verification**: Verify package source integrity and prefer trusted registries and signed artifacts when available.
- **SBOM and Inventory Tracking**: Maintain current dependency inventory (including transitive packages) to accelerate impact analysis during advisories.
- **End-of-Life Component Policy**: Replace unsupported runtimes, frameworks, and libraries on a defined timeline; do not defer EOL remediation indefinitely.
- **Post-Patch Verification**: After applying critical patches, validate control effectiveness with targeted checks and document evidence in reports.
'@;

    "conventions\testing.md" = @'
# Test-Driven Development (TDD)
- **TDD Enforcement**: You MUST write the failing tests in the `tests/` directory **FIRST**, and ONLY write the business implementation in `src/` after tests are written.
- **MockDB**: Use `src/utils/mockFactory.ts` instead of hitting the live PostgreSQL database instance for unit tests.
- **LOC Coverage (Line of Code Coverage) Definition**: `LOC Coverage = (Executed Coverable Lines / Total Coverable Lines) * 100`.
- **Coverable Lines Scope**: Count executable lines only; exclude blank lines, comments, generated files, and non-executable declarations.

## Common Test and Software Quality Strategies
- **Risk-Based Test Pyramid**: Prioritize many unit tests, targeted integration tests, and a small number of end-to-end smoke tests.
- **Branch Coverage Focus**: Measure branch coverage in addition to line coverage for critical logic and decision paths.
- **Critical-Path Coverage Targets**: Apply stricter coverage expectations for security-sensitive and business-critical modules.
- **Changed-Code Accountability**: New or modified behavior MUST include corresponding tests in the same change set.
- **Regression Safeguards**: Preserve tests for previously fixed defects to prevent recurrence.
- **Deterministic Test Design**: Avoid flaky tests by controlling time, randomness, and external dependencies.
- **Contract and Boundary Testing**: Verify request/response contracts and failure handling at system boundaries.
- **Golden/Snapshot Validation**: For template-driven outputs, use golden or snapshot tests to detect unintended drift.
- **Security Test Coverage**: Include tests for auth, input validation, secret handling, and fail-closed behavior.
- **Mutation Testing for Core Rules**: Periodically apply mutation testing to critical modules to assess assertion quality.

## Coverage Governance
- **Minimum Baseline**: Maintain at least 80% line coverage for the repository unless an approved exception exists.
- **No Silent Gaps**: Untested critical-path code is treated as incomplete work.
- **Evidence in Reports**: Record notable coverage changes and test strategy updates in project reports.
'@;

    "conventions\external-engagement.md" = @'
# External Engagement and Project Promotion Policy

## Purpose and Scope
- **Community Value First**: External participation MUST optimize for useful, accurate contribution and long-term credibility rather than raw posting volume, impressions, or short-term traffic.
- **Covered Surfaces**: This policy applies to forums, social networks, community chats, issue discussions, comment threads, direct messages, and other public or semi-public channels used on behalf of a project.
- **Project-Neutral Application**: Apply the same standard to every project, product, article, benchmark, or repository being represented.

## Mandatory Four-Gate Thread Selection
All four gates MUST pass before engaging in a thread with a current or possible future project-promotion objective. If any gate fails, skip the thread; reach or popularity alone is never sufficient.

1. **Direct Relevance**: The discussion directly concerns a problem, workflow, capability, or evidence area that the project genuinely addresses, and the responder can add specific value without forcing a project mention.
2. **Current Heat**: The discussion is active now, demonstrated by recency and continuing substantive participation rather than historical popularity alone.
3. **Meaningful Reach**: The thread has credible visibility within the intended audience, based on community fit and active readership rather than vanity metrics alone.
4. **Natural Project Fit**: The conversation has a credible, context-driven path to a later project introduction because the project directly answers a question, supplies requested evidence, or provides a relevant implementation. A hypothetical opportunity to insert a link does not pass this gate.

Selection decisions SHOULD record a short rationale for each gate and the observation time when the engagement is part of a managed outreach campaign.

## Discussion-First Participation
- **Standalone Value**: The first response MUST stand on its own as a useful contribution. Do not require a project mention or link for the response to make sense.
- **Thread Specificity**: Address the actual question, evidence, or tradeoff raised in the thread. Do not use repetitive templates, metric dumping, cold direct messages, or cross-post spam.
- **No Manufactured Setup**: Do not seed questions, coordinate fake engagement, or steer a discussion deceptively to create an opening for promotion.
- **Natural Cadence**: Do not batch-post promotional replies or flood adjacent threads. Pace participation according to genuine conversation and allow existing discussions to develop before adding follow-ups.

## Transparent Project Introduction
- **Context-Driven Mention**: Introduce a project only when another participant requests a resource or when the project becomes directly useful to the discussion. Do not retroactively force a mention merely because the initial response received attention.
- **Affiliation Disclosure**: Disclose the relationship to the project at the first mention using plain language such as "I maintain this project" or "I worked on this benchmark."
- **Link Limit**: At most one project link may be shared in a thread unless another participant explicitly requests a different relevant artifact.
- **Relevant Destination**: Link to the most useful source, benchmark, documentation page, or repository for the question, not a generic landing page chosen only for traffic.
- **Evidence Discipline**: Technical and performance claims MUST be supported by reproducible evidence. Clearly distinguish measured results, design intent, personal experience, and unverified expectations.

## Platform Integrity and Stop Conditions
- **Platform Compliance**: Respect platform rules, community-specific promotion policies, moderator directions, rate limits, and disclosure requirements even when they are stricter than this standard.
- **Authentic Identity**: Do not impersonate independent users, hide a material affiliation, fabricate endorsements, purchase or coordinate votes, or use undisclosed accounts to amplify a project.
- **No Unsolicited Escalation**: Do not move a public exchange into direct messages unless the other participant requests it or sensitive details genuinely require a private channel.
- **Stop on Resistance**: If participants or moderators indicate that promotion is unwelcome, stop mentioning or linking the project in that discussion.
'@;

    "conventions\performance.md" = @'
# Performance & Optimization
- **Algorithmic Limit (Big-O)**: Avoid nested loops that result in O(N²) for data processing. Utilize HashMaps or Set lookups to achieve O(N) where applicable.
- **Data Fetching Limitations**: Unbounded queries (`SELECT * FROM users`) are explicitly FORBIDDEN. Queries MUST be paginated (`LIMIT`).
- **Main Thread**: Blocking the main thread for over 50ms in frontend components is considered a violation.
'@;

    "conventions\observability.md" = @'
# Telemetry & Logging
- **Structured Logs**: Standard `console.log()` is FORBIDDEN in the backend. All logs MUST be structured JSON including `event_id`, `timestamp`, and `user_id`.
- **Custom Metrics**: When processing core transactions, autonomously add metrics (e.g., `orders_processed_total`).
- **Distributed Tracing**: Propagate OpenTelemetry logic for all inter-service `.fetch()` calls.
'@;

    "checklists\pr-review.md" = @'
# Autonomous PR Checklist
*AI Agents MUST read and verify every item below before generating a Git commit or PR.*
- [ ] Read the actual diff and confirm the changed files match the requested scope.
- [ ] Are all unit tests and E2E tests passing?
- [ ] Did I verify the CVSS score of all new dependencies introduced?
- [ ] All new dependencies are declared and pinned, with dependency confusion and supply-chain risk checked.
- [ ] No hardcoded secrets, tokens, connection strings, private keys, or real credentials were added.
- [ ] GitHub Actions permissions are least privilege, with write scopes only at job level when required.
- [ ] Did I verify that all added or changed communication paths use PQC/CNSA 2.0-compliant ML-KEM/ML-DSA or approved CRYSTALS/PQC successor algorithms?
- [ ] Did I verify that local CGA-Relay executable sync was attempted first when available, ContextGraph indexing/change aggregation completed through `cga-relay`, and no direct API or `cga-mcp-server` fallback was counted as official success?
- [ ] Did I auto-update the Mermaid diagrams in `.adc/knowledge/diagrams/` to match my architectural modifications?
- [ ] Are Docker CPU/Memory resource limits properly set as environment variables?
- [ ] Validation evidence is included in the PR body, including exact tests/checks run or a documented reason when unavailable.
'@;

        "contextgraph-edge-agent\mcp\mcp-servers.json" = @'
{
  "mcpServers": {
        "cga-relay": {
            "transport": "http",
            "url": "http://localhost:18001/mcp/sse",
            "headers": {
                "Authorization": "Bearer ${CONTEXTGRAPH_MCP_TOKEN}",
                "X-Project-ID": "${CONTEXTGRAPH_PROJECT_ID}"
            },
            "env": {
                "CONTEXTGRAPH_MCP_TOKEN": "${CONTEXTGRAPH_MCP_TOKEN}",
                "CONTEXTGRAPH_EDGE_AGENT_TOKEN": "${CONTEXTGRAPH_EDGE_AGENT_TOKEN}",
                "CONTEXTGRAPH_PROJECT_ID": "${CONTEXTGRAPH_PROJECT_ID}",
                "CONTEXTGRAPH_RELAY_URL": "${CONTEXTGRAPH_RELAY_URL}"
            },
            "description": "Mandatory Context Graph Agent (CGA) relay endpoint profile for ADC projects; required for all ContextGraph indexing and project change information aggregation, and attempted before cga-mcp-server for non-indexing MCP operations"
        },
        "cga-mcp-server": {
            "transport": "http",
            "url": "http://localhost:18001/mcp/sse",
            "headers": {
                "Authorization": "Bearer ${CONTEXTGRAPH_MCP_TOKEN}",
                "X-Project-ID": "${CONTEXTGRAPH_PROJECT_ID}"
            },
            "env": {
                "CONTEXTGRAPH_MCP_TOKEN": "${CONTEXTGRAPH_MCP_TOKEN}",
                "CONTEXTGRAPH_PROJECT_ID": "${CONTEXTGRAPH_PROJECT_ID}"
            },
            "description": "Context Graph Agent (CGA) MCP Server fallback endpoint profile for ADC projects (language-agnostic MCP wiring)"
        },
    "local-postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost/mydb"]
    }
  }
}
'@;

    "diagrams\architecture.mmd" = @'
graph TD;
    Client-->API_Gateway;
    API_Gateway-->Auth_Service;
    API_Gateway-->Core_Engine;
    Core_Engine-->PostgreSQL[(Database)];
    Core_Engine-->Redis[(Cache)];
'@;

    "diagrams\data-flow.mmd" = @'
sequenceDiagram
    participant U as User (Client)
    participant A as API Gateway
    participant C as Core Engine
    participant DB as Database
    
    U->>A: POST /orders (Payload)
    A->>C: Validate & Route Request
    C->>DB: INSERT INTO orders
    DB-->>C: Return Order ID
    C-->>A: Format Response (JSON)
    A-->>U: 201 Created (Order ID)
'@;

    "status.md" = @'
# Project Status
**Current Phase:** Phase 1 - Foundation & Prototyping
**Active Goals:**
- Establish base ADC infrastructure
- Set up continuous integration
- Initialize core database schemas

**Recent Changes:**
- [2026-03-13] Drafted the initial ADC specification.
'@;

    "adcignore" = @'
node_modules/
src/dist/
build/
.env
.git/
coverage/
tmp/
src/log/
'@
}

foreach ($key in $Files.Keys) {
    Set-Content -Path (Join-Path $TargetDir $key) -Value $Files[$key] -Encoding UTF8
}

# Create empty structural placeholders to demonstrate full tree scope
$EmptyFiles = @(
    "project-roadmap.md", "development-phases.md", "glossary.md",
    "conventions\structure.md", "conventions\frontend.md", "conventions\backend.md",
    "conventions\data-engineering.md",
    "adr\001-why-we-use-redis.md", "skills\sample-skill\SKILL.md"
)
foreach ($file in $EmptyFiles) {
    $path = Join-Path $TargetDir $file
    if (-Not (Test-Path $path)) {
        New-Item -ItemType File -Force -Path $path | Out-Null
    }
}

Write-Host "Success! Complete ADC template scaffolded at $TargetDir."


