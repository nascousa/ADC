from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def _read(rel_path: str) -> str:
    return (ROOT / rel_path).read_text(encoding="utf-8")


def test_prompt_rules_has_core_quality_sections() -> None:
    content = _read(".templates/prompt-rules.md")

    required_sections = [
        "## Mandatory Core Rules",
        "## Repository and Workflow Rules",
        "## ContextGraph Use Policy",
        "## ContextGraph Retrieval and Token Policy",
        "## ContextGraph-First Trigger Conditions",
        "## Allowed Exceptions",
    ]

    for section in required_sections:
        assert section in content


def test_security_convention_has_patch_and_update_strategies() -> None:
    content = _read(".templates/standards/conventions/security.md")

    required_entries = [
        "## Version, Update, and Patch Security Strategies",
        "- **Security-First Versioning**",
        "- **Patch Cadence Policy**",
        "- **Time-Bounded Exceptions**",
        "- **Post-Patch Verification**",
    ]

    for entry in required_entries:
        assert entry in content


def test_security_convention_requires_pqc_cnsa2_communications() -> None:
    security = _read(".templates/standards/conventions/security.md")
    prompt_rules = _read(".templates/prompt-rules.md")
    terminology = _read(".templates/knowledge/terminology.md")
    amendments = _read(".templates/knowledge/amendments.md")
    pr_checklist = _read(".templates/standards/checklists/pr-review.md")
    root_pr_template = _read(".github/pull_request_template.md")
    template_pr_template = _read(".templates/.github/pull_request_template.md")
    root_policy_ci = _read(".github/workflows/policy-ci.yml")
    template_policy_ci = _read(".templates/.github/workflows/policy-ci.yml")
    generator = _read("src/scripts/generate-adc-template.ps1")
    readme = _read("README.md")

    required_entries = [
        "## Post-Quantum Communications Standard (PQC/CNSA 2.0)",
        "All project communication paths MUST use CNSA 2.0-aligned post-quantum cryptography",
        "ML-KEM (NIST FIPS 203 / CRYSTALS-Kyber lineage)",
        "ML-DSA (NIST FIPS 204 / CRYSTALS-Dilithium lineage)",
        "default to ML-KEM-1024",
        "default to ML-DSA-87",
        "PQC/CNSA 2.0 communications policy applied",
        "CGA relay-first policy applied",
        "apply the CGA relay-first policy",
        "PQC/CNSA 2.0 baseline",
        "| **PQC** | Post-Quantum Cryptography",
        "| **CNSA 2.0** | Commercial National Security Algorithm Suite 2.0",
        "mandatory PQC/CNSA 2.0 communication baseline",
        "**Version:** 1.1.25",
        "**Date:** 2026-06-12 (mandatory CGA relay-first policy)",
    ]
    combined = "\n".join(
        [
            security,
            prompt_rules,
            terminology,
            amendments,
            pr_checklist,
            root_pr_template,
            template_pr_template,
            root_policy_ci,
            template_policy_ci,
            generator,
            readme,
        ]
    )

    for entry in required_entries:
        assert entry in combined


def test_testing_convention_has_quality_strategy_section() -> None:
    content = _read(".templates/standards/conventions/testing.md")

    required_entries = [
        "## Common Test and Software Quality Strategies",
        "- **Branch Coverage Focus**",
        "- **Golden/Snapshot Validation**",
        "## Coverage Governance",
        "- **Minimum Baseline**: Maintain at least 80% line coverage",
    ]

    for entry in required_entries:
        assert entry in content


def test_frontend_convention_has_browser_debugging_and_darkmode_defaults() -> None:
    content = _read(".templates/standards/conventions/frontend.md")

    required_entries = [
        "## Default Web App Experience",
        "- **Dark Mode Default**",
        "Vanta.js net-style background",
        "white dots/lines at 15% opacity",
        "## Browser Debugging Policy",
        "built-in browser shared page",
        "BrowserAgent (BA) project plus browser extension",
    ]

    for entry in required_entries:
        assert entry in content


def test_backend_and_data_conventions_have_default_web_stack() -> None:
    backend = _read(".templates/standards/conventions/backend.md")
    data = _read(".templates/standards/conventions/data-engineering.md")

    backend_required_entries = [
        "## Default API Runtime",
        "- **FastAPI Default**",
        "Pydantic schemas",
        "## Default Web App Data Pairing",
        "- **pgvector Default**",
    ]
    data_required_entries = [
        "PostgreSQL Vector Policy (`pgvector`)",
        "- **Default Web App Store**",
        "PostgreSQL plus `pgvector`",
    ]

    for entry in backend_required_entries:
        assert entry in backend
    for entry in data_required_entries:
        assert entry in data


def test_devops_convention_has_cicd_github_webhook_policy() -> None:
    content = _read(".templates/standards/conventions/devops.md")

    required_entries = [
        "## CI/CD Policy (GitHub + Webhook Deploy)",
        "CICD=enabled",
        "GITHUB_TOKEN",
        "git@github.com:nascousa/ADC.git",
        "DEPLOY_WEBHOOK_URL",
        "main -> production",
        "Webhook-driven auto deploy",
    ]

    for entry in required_entries:
        assert entry in content


def test_cicd_preflight_gate_policy_is_explicit() -> None:
    runbook = _read(".templates/standards/runbooks/002-cicd-github-webhook-debug.md")

    runbook_required_entries = [
        "Preflight Gate",
        "CICD=enabled",
        "GITHUB_TOKEN",
        "DEPLOY_WEBHOOK_URL",
        "Validate GitHub token",
        "Validate deployment webhook endpoint reachability",
    ]
    for entry in runbook_required_entries:
        assert entry in runbook


def test_all_powershell_scripts_live_under_src_scripts() -> None:
    root_ps1_files = list(ROOT.glob("*.ps1"))
    assert not root_ps1_files


def test_devops_convention_has_required_compose_healthcheck_block() -> None:
    content = _read(".templates/standards/conventions/devops.md")

    required_entries = [
        "## Docker Compose Health Check Policy",
        "healthcheck:",
        "- CMD",
        "- curl",
        "- '-f'",
        "- 'http://localhost:8000/health'",
        "interval: 30s",
        "timeout: 10s",
        "retries: 3",
        "start_period: 40s",
    ]

    for entry in required_entries:
        assert entry in content


def test_contextgraph_mcp_template_uses_cga_relay_first_with_local_dev_sse_endpoint_and_headers() -> None:
    mcp_profile = _read(".templates/contextgraph-edge-agent/mcp/mcp-servers.json")
    bootstrap = _read(".templates/bootstrap.md")
    devops = _read(".templates/standards/conventions/devops.md")

    required_mcp_entries = [
        '"cga-relay"',
        '"cga-mcp-server"',
        '"url": "http://localhost:18001/mcp/sse"',
        '"Authorization": "Bearer ${CONTEXTGRAPH_MCP_TOKEN}"',
        '"X-Project-ID": "${CONTEXTGRAPH_PROJECT_ID}"',
        '"CONTEXTGRAPH_RELAY_URL": "${CONTEXTGRAPH_RELAY_URL}"',
        "Mandatory relay-first Context Graph Agent (CGA) relay endpoint profile",
        "Context Graph Agent (CGA) MCP Server fallback endpoint profile",
    ]
    for entry in required_mcp_entries:
        assert entry in mcp_profile

    assert mcp_profile.index('"cga-relay"') < mcp_profile.index('"cga-mcp-server"')
    assert "CONTEXTGRAPH_MCP_SERVER_URL=http://localhost:18001/mcp/sse" in bootstrap
    assert "CONTEXTGRAPH_RELAY_URL=http://localhost:18001/mcp/sse" in bootstrap
    assert "http://localhost:18001/mcp/sse" in devops


def test_cga_is_formally_defined_as_context_graph_agent() -> None:
    terminology = _read(".templates/knowledge/terminology.md")
    index = _read(".templates/index.md")
    bootstrap = _read(".templates/bootstrap.md")
    devops = _read(".templates/standards/conventions/devops.md")
    mcp_profile = _read(".templates/contextgraph-edge-agent/mcp/mcp-servers.json")
    generator = _read("src/scripts/generate-adc-template.ps1")

    required_entries = [
        "| **CGA** | Context Graph Agent |",
        "Context Graph Agent (CGA) Admin UI",
        "Context Graph Agent (CGA) relay/MCP credentials",
        "Context Graph Agent Model Context Protocol endpoint",
        "Mandatory relay-first Context Graph Agent (CGA) relay endpoint profile",
    ]
    combined = "\n".join([terminology, index, bootstrap, devops, mcp_profile, generator])

    for entry in required_entries:
        assert entry in combined

    assert "ContextGraph" + "Agent" not in combined


def test_contextgraph_policy_requires_registration_reporting_and_indexing() -> None:
    bootstrap = _read(".templates/bootstrap.md")
    devops = _read(".templates/standards/conventions/devops.md")
    prompt_rules = _read(".templates/prompt-rules.md")
    index = _read(".templates/index.md")
    mcp_profile = _read(".templates/contextgraph-edge-agent/mcp/mcp-servers.json")
    generator = _read("src/scripts/generate-adc-template.ps1")
    onboard_skill = _read(".copilot/skills/adc-onboard/SKILL.md")

    required_entries = [
        "CONTEXTGRAPH_BRIEFING_API_URL=http://localhost:18001/api/project/work-briefing/activity",
        "CONTEXTGRAPH_RELAY_URL=http://localhost:18001/mcp/sse",
        "CONTEXTGRAPH_INDEXING_POLICY=auto-incremental",
        "- **Mandatory Registration**",
        "- **Automatic Relay Installation**",
        "Project bootstrap MUST automatically install or refresh the paired `cga-relay` profile",
        "Relay-First Execution Policy",
        "All ContextGraph MCP retrieval, indexing, progress-reporting, and integration operations MUST attempt `cga-relay` first",
        "`cga-mcp-server` MAY be used only after relay is unavailable",
        "fallback reason MUST be documented",
        "Local dev MCP clients MUST route `cga-relay`",
        "## CGA Progress Reporting and Indexing Policy",
        "workassist_record_activity",
        "index_repo_changes(repo_path)",
        "MUST run `index_repo_changes(repo_path)` through `cga-relay` first",
        "Register every project in Context Graph Agent (CGA)",
        "Periodically report project progress to CGA",
        "Mandatory relay-first Context Graph Agent (CGA) relay endpoint profile",
        "mandatory relay-first `cga-relay` workflow",
        "cga-relay",
    ]
    combined = "\n".join([bootstrap, devops, prompt_rules, index, mcp_profile, generator, onboard_skill])

    for entry in required_entries:
        assert entry in combined

    forbidden_entries = [
        "Project bootstrap SHOULD automatically install or refresh the paired `cga-relay` profile",
        "agents SHOULD run `index_repo_changes(repo_path)` through `cga-relay` first",
        "Local dev MCP clients SHOULD route `cga-relay`",
        "enabled as the preferred profile",
        "prefer CGA relay wiring",
    ]
    for entry in forbidden_entries:
        assert entry not in combined


def test_generate_adc_template_script_contains_default_web_app_policies() -> None:
    script = _read("src/scripts/generate-adc-template.ps1")

    required_entries = [
        '"conventions\\frontend.md"',
        '"conventions\\backend.md"',
        '"conventions\\data-engineering.md"',
        "built-in browser shared page",
        "BrowserAgent (BA) project plus browser extension",
        "Vanta.js net-style background",
        "FastAPI Default",
        "PostgreSQL plus `pgvector`",
        "CONTEXTGRAPH_BRIEFING_API_URL=http://localhost:18001/api/project/work-briefing/activity",
        "CONTEXTGRAPH_RELAY_URL=http://localhost:18001/mcp/sse",
        "cga-relay",
        "index_repo_changes(repo_path)",
    ]

    for entry in required_entries:
        assert entry in script


def test_generate_adc_template_script_reports_template_generation_to_contextgraph() -> None:
    script = _read("src/scripts/generate-adc-template.ps1")

    required_entries = [
        "Send-ContextGraphWorkBriefingActivity",
        "template_generation",
        "CONTEXTGRAPH_PROJECT_ID",
        "/api/project/work-briefing/activity",
    ]

    for entry in required_entries:
        assert entry in script


def test_adc_skills_use_current_contextgraph_standard() -> None:
    onboard = _read(".copilot/skills/adc-onboard/SKILL.md")
    update = _read(".copilot/skills/adc-update/SKILL.md")
    combined = "\n".join([onboard, update])

    required_entries = [
        "contextgraph-edge-agent",
        "cga-relay",
        "cga-mcp-server",
        "Context Graph Agent (CGA)",
        "CONTEXTGRAPH_BRIEFING_API_URL",
        "index_repo_changes(repo_path)",
        "FastAPI",
        "PostgreSQL with `pgvector`",
        "report-progress",
        "tests/test_template_quality.py",
        "D:\\Repos\\ADC",
    ]
    forbidden_entries = [
        "rd-" + "onboard",
        "rd-" + "edge-agent",
        "Repo" + "Depot",
        "RD " + "MCP",
        "RD " + "project",
        "R" + "DA",
        "R" + "DA" + "+R" + "D",
        "ContextGraph" + "/CGA",
        "ContextGraph" + "Agent",
        "src/tests/test_template_quality.py",
        "D:\\Repos\\ARKSOFT\\ADC",
    ]

    for entry in required_entries:
        assert entry in combined
    for entry in forbidden_entries:
        assert entry not in combined


