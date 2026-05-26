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


def test_contextgraph_mcp_template_uses_local_dev_sse_endpoint_and_headers() -> None:
    mcp_profile = _read(".templates/contextgraph-edge-agent/mcp/mcp-servers.json")
    bootstrap = _read(".templates/bootstrap.md")
    devops = _read(".templates/standards/conventions/devops.md")

    required_mcp_entries = [
        '"cga-mcp-server"',
        '"url": "http://localhost:18001/mcp/sse"',
        '"Authorization": "Bearer ${CONTEXTGRAPH_MCP_TOKEN}"',
        '"X-Project-ID": "${CONTEXTGRAPH_PROJECT_ID}"',
    ]
    for entry in required_mcp_entries:
        assert entry in mcp_profile

    assert "CONTEXTGRAPH_MCP_SERVER_URL=http://localhost:18001/mcp/sse" in bootstrap
    assert "http://localhost:18001/mcp/sse" in devops


def test_contextgraph_policy_requires_registration_reporting_and_indexing() -> None:
    bootstrap = _read(".templates/bootstrap.md")
    devops = _read(".templates/standards/conventions/devops.md")
    prompt_rules = _read(".templates/prompt-rules.md")

    required_entries = [
        "CONTEXTGRAPH_BRIEFING_API_URL=http://localhost:18001/api/project/work-briefing/activity",
        "CONTEXTGRAPH_INDEXING_POLICY=auto-incremental",
        "- **Mandatory Registration**",
        "- **Automatic MCP Installation**",
        "## CGA Progress Reporting and Indexing Policy",
        "workassist_record_activity",
        "index_repo_changes(repo_path)",
        "Register every project in CGA",
        "Periodically report project progress to CGA",
    ]
    combined = "\n".join([bootstrap, devops, prompt_rules])

    for entry in required_entries:
        assert entry in combined


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


