# Constitutional Amendments
*All changes to the rules inside the `.adc` directory MUST be proposed via PR with the `[AMENDMENT]` prefix. It MUST NOT be modified autonomously without human ratification.*

- **2026-03-13**: Digital Constitution initial ratification. V1.0.0 created.
- **2026-03-23**: Added ContextGraph integration policy in `standards/conventions/devops.md`; local setup now uses the Context Graph Agent (CGA) Admin UI at `http://localhost:18001/admin` and enforces PR traceability/MCP alignment.
- **2026-04-18**: Added `cga-mcp-server` as the ADC baseline MCP profile so downstream ADC projects auto-inherit CGA MCP Server wiring and guidance.
- **2026-04-18**: Updated CGA MCP baseline to endpoint-first, language-agnostic wiring so repositories are not forced to provide a local Node entrypoint.
- **2026-04-18**: Added default token generation policy: unless explicitly overridden by target system requirements, tokens MUST use cryptographically random 35-character values restricted to `A-Za-z0-9`.
- **2026-05-26**: Standardized the ADC MCP profile name to `cga-mcp-server`, set the default local dev SSE endpoint to `http://localhost:18001/mcp/sse`, and required Authorization/X-Project-ID headers in the standard profile.
- **2026-05-26**: Added default web-app standards for built-in browser shared-page debugging, FastAPI, PostgreSQL `pgvector`, dark mode, Vanta.js login backgrounds, CGA progress reporting, and automatic change indexing.
- **2026-05-28**: Aligned `adc-onboard` and `adc-update` workflow skills with the current Context Graph Agent (CGA) standard, replacing obsolete predecessor guidance with `contextgraph-edge-agent`, `cga-mcp-server`, CGA progress reporting, and incremental indexing expectations.
- **2026-06-02**: Defined CGA as the formal abbreviation for Context Graph Agent across ADC terminology, onboarding, and MCP profile templates.
- **2026-06-04**: Added the mandatory PQC/CNSA 2.0 communication baseline requiring ML-KEM/ML-DSA or approved CNSA 2.0 PQC successors for all project communication paths.
- **2026-06-10**: Added `cga-relay` as the preferred CGA MCP profile before `cga-mcp-server`, retained `cga-mcp-server` as fallback, and standardized the expanded name to Context Graph Agent (CGA).
- **2026-06-12**: Elevated CGA relay precedence to a mandatory relay-first policy for ContextGraph MCP operations before `cga-mcp-server`, with fallback reasons documented; the 2026-06-15 amendment supersedes indexing fallback behavior.
- **2026-06-15**: Strengthened ADC indexing governance so all ADC-compliant projects MUST complete initial, incremental, and change indexing through `cga-relay`; `cga-mcp-server` fallback can document relay outages but does not count as official indexing completion.
- **2026-06-15**: Broadened CGA relay governance so all ADC-compliant projects MUST aggregate any meaningful project change information into CGA through `cga-relay`, including change summaries, indexing metadata, progress, validation, release, blocker, risk, and PR/PBI events.
- **2026-07-01**: Added local CGA-Relay executable priority for project status synchronization. When the release executable is available, agents MUST run `sync --config %USERPROFILE%\.cga\agent.env --namespace account --project-tag <project_tag>` before MCP profile or fallback paths.
- **2026-07-01**: Added PR governance gates requiring actual diff review, declared and pinned dependencies, no hardcoded secrets, least-privilege GitHub Actions permissions, and explicit validation evidence in ADC PR checklists/templates.
- **2026-07-21**: Added a project-neutral external engagement and promotion convention with mandatory four-gate thread selection, discussion-first participation, transparent affiliation disclosure, evidence-backed claims, link limits, natural pacing, and anti-spam safeguards.


