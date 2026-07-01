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

# 5. Start ContextGraph services
npm run contextgraph-mcp:start      # Starts src/contextgraph-mcp server (default: http://localhost:3001/mcp)
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
# Check optional repository-local MCP bridge health (only if this repo ships one)
curl http://localhost:3001/mcp/health

# Check local edge agent health (src/contextgraph-edge-agent)
curl http://localhost:3002/edges/health

# Verify ContextGraph local dev API connectivity
curl http://localhost:18001/health
```


