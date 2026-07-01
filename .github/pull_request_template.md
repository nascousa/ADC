## Summary

Describe what changed and why.

## Validation

- [ ] Read the actual diff and confirmed changed files match the stated scope
- [ ] Unit/E2E tests pass locally
- [ ] New dependencies were checked for CVEs/CVSS threshold policy
- [ ] All new dependencies are declared and pinned, and dependency confusion/supply-chain risk was checked
- [ ] No hardcoded secrets, tokens, connection strings, private keys, or real credentials were added
- [ ] GitHub Actions permissions are least privilege when workflow files changed
- [ ] Validation evidence includes exact tests/checks run, or a documented reason when validation was unavailable
- [ ] This change was developed on `dev/*` (or `hotfix/*`) branch and not committed directly to `main`
- [ ] `docs/deploy_key.md` is updated with the current public deploy key when deploy credentials changed
- [ ] Mermaid diagrams were updated if architecture/data-flow/schema changed
- [ ] Docker CPU/Memory limits are configured via env variables when applicable

## Policy Checklist

- [ ] JWT/token entropy policy applied (algorithm, key strength, claims, TTL, rotation)
- [ ] PQC/CNSA 2.0 communications policy applied (ML-KEM/ML-DSA or approved CRYSTALS/PQC successor)
- [ ] CGA relay-first policy applied; local CGA-Relay executable sync was attempted first when available, and ContextGraph indexing/change aggregation completed through `cga-relay` with no direct API or `cga-mcp-server` fallback counted as success
- [ ] Data policy applied for pgvector/sqlite-vec/graph usage and index/query constraints
