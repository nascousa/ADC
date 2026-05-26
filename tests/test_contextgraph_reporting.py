from __future__ import annotations

from fastapi.testclient import TestClient

import backend.main as main_module
from backend.contextgraph_reporter import ContextGraphWorkBriefingReporter


def test_reporter_derives_project_briefing_endpoint_from_mcp_server(monkeypatch) -> None:
    monkeypatch.delenv("CONTEXTGRAPH_BRIEFING_API_URL", raising=False)
    monkeypatch.setenv("CONTEXTGRAPH_MCP_SERVER_URL", "http://localhost:18001/mcp/sse")
    monkeypatch.setenv("CONTEXTGRAPH_EDGE_AGENT_TOKEN", "edge-token")
    monkeypatch.setenv("CONTEXTGRAPH_PROJECT_ID", "ADC123")

    reporter = ContextGraphWorkBriefingReporter.from_env(workspace_name="ADC")

    assert reporter is not None
    assert reporter.api_url == "http://localhost:18001/api/project/work-briefing/activity"
    assert reporter.project_id == "ADC123"
    assert reporter.workspace_name == "ADC"


def test_startup_reports_service_start_when_reporter_is_configured(monkeypatch) -> None:
    captured_payloads: list[dict] = []

    class FakeReporter:
        def report_activity(self, payload: dict) -> dict:
            captured_payloads.append(payload)
            return {"ok": True}

    monkeypatch.setattr(main_module, "_contextgraph_reporter", FakeReporter())

    with TestClient(main_module.app) as client:
        response = client.get("/health")

    assert response.status_code == 200
    assert len(captured_payloads) == 1
    assert captured_payloads[0]["event_type"] == "service_start"
    assert captured_payloads[0]["title"] == "ADC service started"
