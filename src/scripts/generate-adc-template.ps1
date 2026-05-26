function Get-ContextGraphWorkBriefingConfig {
    $projectId = if ($env:CONTEXTGRAPH_PROJECT_ID) { [string]$env:CONTEXTGRAPH_PROJECT_ID } else { '' }
    $token = if ($env:CONTEXTGRAPH_EDGE_AGENT_TOKEN) {
        [string]$env:CONTEXTGRAPH_EDGE_AGENT_TOKEN
    } elseif ($env:CONTEXTGRAPH_MCP_TOKEN) {
        [string]$env:CONTEXTGRAPH_MCP_TOKEN
    } else {
        ''
    }

    $apiUrl = if ($env:CONTEXTGRAPH_BRIEFING_API_URL) {
        [string]$env:CONTEXTGRAPH_BRIEFING_API_URL
    } elseif ($env:CONTEXTGRAPH_UPSTREAM_URL) {
        (([string]$env:CONTEXTGRAPH_UPSTREAM_URL).TrimEnd('/')) + '/api/project/work-briefing/activity'
    } elseif ($env:CONTEXTGRAPH_MCP_SERVER_URL) {
        $mcpUrl = ([string]$env:CONTEXTGRAPH_MCP_SERVER_URL).TrimEnd('/')
        if ($mcpUrl.EndsWith('/mcp/sse')) {
            $mcpUrl.Substring(0, $mcpUrl.Length - 8) + '/api/project/work-briefing/activity'
        } elseif ($mcpUrl.EndsWith('/mcp/messages')) {
            $mcpUrl.Substring(0, $mcpUrl.Length - 13) + '/api/project/work-briefing/activity'
        } elseif ($mcpUrl.EndsWith('/mcp')) {
            $mcpUrl.Substring(0, $mcpUrl.Length - 4) + '/api/project/work-briefing/activity'
        } else {
            $mcpUrl + '/api/project/work-briefing/activity'
        }
    } else {
        ''
    }

    return @{
        Enabled = (-not [string]::IsNullOrWhiteSpace($apiUrl)) -and (-not [string]::IsNullOrWhiteSpace($token)) -and (-not [string]::IsNullOrWhiteSpace($projectId))
        ApiUrl = [string]$apiUrl
        ProjectId = [string]$projectId
        Token = [string]$token
    }
}

function Send-ContextGraphWorkBriefingActivity {
    param(
        [Parameter(Mandatory)][string]$EventType,
        [Parameter(Mandatory)][string]$Title,
        [string]$Summary = '',
        [string]$Status = '',
        [string]$WorkspaceName = 'ADC',
        [string]$ExternalId = '',
        [hashtable]$Metadata = @{},
        [string[]]$Tags = @()
    )

    $config = Get-ContextGraphWorkBriefingConfig
    if (-not $config.Enabled) {
        return
    }

    $payload = @{
        project_id = $config.ProjectId
        workspace_name = $WorkspaceName
        event_type = $EventType
        title = $Title
        summary = $Summary
        status = $Status
        tags = @($Tags | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        metadata = if ($Metadata) { $Metadata } else { @{} }
    }
    if ($ExternalId) {
        $payload.external_id = $ExternalId
    }

    try {
        Invoke-RestMethod -Uri $config.ApiUrl -Method Post -Headers @{
            Authorization = "Bearer $($config.Token)"
            'X-Project-ID' = $config.ProjectId
        } -ContentType 'application/json' -Body ($payload | ConvertTo-Json -Depth 10) | Out-Null
    } catch {
        Write-Warning "ContextGraph work briefing report failed: $($_.Exception.Message)"
    }
}

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
- **ContextGraph Project**: Central repository and artifact management system (registration via CGA Admin UI at `http://localhost:18001/admin`)
- **ContextGraph Edge Agent** (`src/contextgraph-edge-agent`): Local execution and orchestration agent
- **CGA MCP Server**: Model Context Protocol endpoint for programmatic ContextGraph access (default local dev SSE endpoint: `http://localhost:18001/mcp/sse`)
- **Initial ContextGraph Indexing**: Immediately after ContextGraph Edge Agent + CGA MCP Server integration, run full-project indexing once so retrieval/review tools can access the entire repository context.

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
# Open CGA Admin UI: http://localhost:18001/admin
# Follow the guided setup to:
#   - Register this project in the ContextGraph catalog
#   - Retrieve CGA MCP server credentials and edge agent token
#   - Store credentials in .env (see step 2 below)

# 2. Configure ContextGraph environment variables
echo "CONTEXTGRAPH_MCP_SERVER_URL=http://localhost:18001/mcp/sse" >> .env
echo "CONTEXTGRAPH_BRIEFING_API_URL=http://localhost:18001/api/project/work-briefing/activity" >> .env
echo "CONTEXTGRAPH_INDEXING_POLICY=auto-incremental" >> .env
echo "CONTEXTGRAPH_EDGE_AGENT_TOKEN=<token-from-cga-admin>" >> .env
echo "CONTEXTGRAPH_PROJECT_ID=<project-id-from-cga-admin>" >> .env
```

After ContextGraph Edge Agent and CGA MCP Server are integrated, initialize a full repository index before starting feature work:

```text
Required one-time bootstrap indexing flow
1) Ensure `mcp-servers.json` contains the `cga-mcp-server` endpoint profile and receives project context from environment variables.
2) Run a full-project indexing call through ContextGraph MCP using:
   - project_id: CONTEXTGRAPH_PROJECT_ID
   - repo_path: repository root
   - changed_files: all tracked source and documentation files
3) Treat indexing as successful only after the ContextGraph service returns a successful completion status.
4) Configure periodic work briefing reports for service starts, feature milestones, validation runs, and releases.
```

For all later changes, run `index_repo_changes(repo_path)` through `cga-mcp-server` so modified source, documentation, configuration, and test content is indexed automatically.

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
- Follow Test-Driven Development (TDD) in `.adc/standards/conventions/testing.md`.
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
- Register every project in CGA and automatically install or refresh the paired `cga-mcp-server` profile before substantial feature work.
- Periodically report project progress to CGA and run `index_repo_changes(repo_path)` after meaningful source, documentation, configuration, or test changes.
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
- Use incremental indexing for changed files; avoid full reindex for routine tasks.
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
- **Authoritative Onboarding URL**: Integration with ContextGraph MUST use the CGA Admin UI at `http://localhost:18001/admin` as the local setup surface for project registration and token creation.
- **Mandatory Registration**: All ADC-compliant projects MUST be registered in CGA before feature work begins unless CGA is temporarily unavailable and the exception is documented.
- **Automatic MCP Installation**: Project bootstrap SHOULD automatically install or refresh the paired `cga-mcp-server` profile in `.adc/contextgraph-edge-agent/mcp/mcp-servers.json` using environment-variable backed credentials.
- **No Unreviewed Deviation**: Agents and developers MUST NOT use alternate ContextGraph onboarding flows unless explicitly approved in the same PR description.
- **Traceability Requirement**: Any PR that introduces or changes ContextGraph integration MUST include a short "ContextGraph integration notes" section describing what step(s) from the onboarding URL were applied.
- **MCP Alignment**: If ContextGraph integration adds or changes external service endpoints or credentials, `mcp-servers.json` MUST be updated in the same change set.

## ContextGraph Edge Agent and ContextGraph MCP Use Policy
- **Responsibility Split**: `contextgraph-edge-agent/` is for local orchestration artifacts (task queues, scratchpad notes, MCP wiring). ContextGraph MCP is for programmatic integration/retrieval against ContextGraph services.
- **Runtime Neutrality**: MCP wiring MUST be language-agnostic by default. Do not require a Node-specific local entrypoint unless that repository explicitly ships and maintains one.
- **Execution Policy**: ContextGraph MCP MUST NOT be used to replace local compile, lint, unit test, or integration test execution. Build/test must run through project-native tooling.
- **Authority Policy**: Outputs from ContextGraph Edge Agent scratchpad/tasks are operational context, not product truth. Canonical product rules remain in constitution/convention/planning files.
- **Network Policy**: Local ContextGraph services are expected on localhost endpoints; upstream ContextGraph access MUST use the configured upstream URL and approved credentials only.
- **Default MCP Endpoint**: Local dev MCP clients SHOULD use `http://localhost:18001/mcp/sse` unless the CGA deployment explicitly advertises a different MCP SSE endpoint.
- **Secret Policy**: Tokens and project identifiers (`CONTEXTGRAPH_MCP_TOKEN`, `CONTEXTGRAPH_EDGE_AGENT_TOKEN`, `CONTEXTGRAPH_PROJECT_ID`) MUST be injected via environment variables and never committed to repository files.
- **Change Policy**: Any PR changing ContextGraph integration behavior MUST update both `bootstrap.md` and `mcp-servers.json`, and include validation notes.

## CGA Progress Reporting and Indexing Policy
- **Automatic Progress Reporting**: Projects SHOULD emit periodic progress reports to CGA through the project work briefing API or `workassist_record_activity` MCP tool for service starts, template generation, feature milestones, validation runs, and releases.
- **Change Indexing**: After meaningful source, documentation, configuration, or test changes, agents SHOULD run `index_repo_changes(repo_path)` through `cga-mcp-server` so CGA indexes modified content.
- **Periodic Indexing**: Long-running projects SHOULD schedule periodic incremental indexing even when no single task explicitly requests it, so CGA remains current.
- **Failure Handling**: If CGA reporting or indexing fails, continue local build/test validation, record the failure in `.adc/contextgraph-edge-agent/scratchpad/session.md`, and retry when CGA is reachable.
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
'@;

    "conventions\security.md" = @'
# Security & Vulnerability Management
- **Inviolable Rule**: Do NOT introduce dependencies with a CVSS score >= 7.0.
- **Input Sanitization**: All external inputs MUST run through the Zod validation middleware before reaching controllers.
- **Secret Management**: NEVER hardcode API keys. All keys MUST be retrieved at runtime via `aws-secrets-manager`.

## Common Security Strategies
- **Least Privilege Access**: Grant users, services, and CI jobs only the minimum permissions required, and review privileges regularly.
- **Defense in Depth**: Apply layered controls across application, infrastructure, and network boundaries so one control failure does not expose critical assets.
- **Secure by Default Configuration**: Default new services to deny-all network posture, strict auth requirements, and disabled debug/admin surfaces.
- **Strong Authentication and Authorization**: Enforce strong identity verification, short-lived credentials, and explicit authorization checks on every protected action.
- **Encryption in Transit and at Rest**: Require TLS for all external and internal service communication and encrypt sensitive persisted data with managed keys.
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
- [ ] Are all unit tests and E2E tests passing?
- [ ] Did I verify the CVSS score of all new dependencies introduced?
- [ ] Did I auto-update the Mermaid diagrams in `.adc/knowledge/diagrams/` to match my architectural modifications?
- [ ] Are Docker CPU/Memory resource limits properly set as environment variables?
'@;

        "contextgraph-edge-agent\mcp\mcp-servers.json" = @'
{
  "mcpServers": {
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
            "description": "CGA MCP Server endpoint profile for ADC projects (language-agnostic MCP wiring)"
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
Send-ContextGraphWorkBriefingActivity -EventType 'template_generation' -Title 'Generated ADC template scaffold' -Summary "ADC template scaffold generated at $TargetDir." -Status 'completed' -ExternalId ("template-generation:" + $TargetDir) -Tags @('adc', 'template') -Metadata @{ targetDir = $TargetDir; fileCount = $Files.Count + $EmptyFiles.Count }


