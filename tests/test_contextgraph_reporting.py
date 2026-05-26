from __future__ import annotations

from fastapi.testclient import TestClient

import backend.main as main_module
from backend.contextgraph_reporter import ContextGraphWorkBriefingReporter, _derive_briefing_api_url


def test_derive_briefing_endpoint_handles_supported_mcp_suffixes() -> None:
    assert _derive_briefing_api_url("") == ""
    assert _derive_briefing_api_url("http://localhost:18001/mcp") == "http://localhost:18001/api/project/work-briefing/activity"
    assert _derive_briefing_api_url("http://localhost:18001/mcp/messages") == "http://localhost:18001/api/project/work-briefing/activity"
    assert _derive_briefing_api_url("http://localhost:18001/mcp/sse/") == "http://localhost:18001/api/project/work-briefing/activity"
    assert _derive_briefing_api_url("http://localhost:18001") == "http://localhost:18001/api/project/work-briefing/activity"


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


def test_reporter_uses_explicit_briefing_api_and_mcp_token_fallback(monkeypatch) -> None:
    monkeypatch.setenv("CONTEXTGRAPH_BRIEFING_API_URL", " http://cga.local/api/project/work-briefing/activity ")
    monkeypatch.delenv("CONTEXTGRAPH_EDGE_AGENT_TOKEN", raising=False)
    monkeypatch.setenv("CONTEXTGRAPH_MCP_TOKEN", "mcp-token")
    monkeypatch.setenv("CONTEXTGRAPH_PROJECT_ID", "ADC456")

    reporter = ContextGraphWorkBriefingReporter.from_env(workspace_name="ADC")

    assert reporter is not None
    assert reporter.api_url == "http://cga.local/api/project/work-briefing/activity"
    assert reporter.token == "mcp-token"


def test_reporter_uses_upstream_url_when_mcp_endpoint_is_missing(monkeypatch) -> None:
    monkeypatch.delenv("CONTEXTGRAPH_BRIEFING_API_URL", raising=False)
    monkeypatch.delenv("CONTEXTGRAPH_MCP_SERVER_URL", raising=False)
    monkeypatch.setenv("CONTEXTGRAPH_UPSTREAM_URL", "http://cga.local/")
    monkeypatch.setenv("CONTEXTGRAPH_EDGE_AGENT_TOKEN", "edge-token")
    monkeypatch.setenv("CONTEXTGRAPH_PROJECT_ID", "ADC789")

    reporter = ContextGraphWorkBriefingReporter.from_env(workspace_name="ADC")

    assert reporter is not None
    assert reporter.api_url == "http://cga.local/api/project/work-briefing/activity"


def test_reporter_from_env_returns_none_when_credentials_are_incomplete(monkeypatch) -> None:
    monkeypatch.setenv("CONTEXTGRAPH_BRIEFING_API_URL", "http://cga.local/api/project/work-briefing/activity")
    monkeypatch.delenv("CONTEXTGRAPH_EDGE_AGENT_TOKEN", raising=False)
    monkeypatch.delenv("CONTEXTGRAPH_MCP_TOKEN", raising=False)
    monkeypatch.setenv("CONTEXTGRAPH_PROJECT_ID", "ADC123")

    assert ContextGraphWorkBriefingReporter.from_env(workspace_name="ADC") is None


def test_report_activity_posts_json_payload(monkeypatch) -> None:
    captured: dict = {}

    class FakeResponse:
        def __enter__(self):
            return self

        def __exit__(self, exc_type, exc, traceback):
            return False

        def read(self) -> bytes:
            return b'{"operation":"created"}'

    def fake_urlopen(http_request, timeout: float):
        captured["url"] = http_request.full_url
        captured["headers"] = dict(http_request.header_items())
        captured["body"] = http_request.data.decode("utf-8")
        captured["timeout"] = timeout
        return FakeResponse()

    monkeypatch.setattr("backend.contextgraph_reporter.request.urlopen", fake_urlopen)
    reporter = ContextGraphWorkBriefingReporter(
        api_url="http://cga.local/api/project/work-briefing/activity",
        project_id="ADC123",
        token="edge-token",
        workspace_name="ADC",
        timeout_sec=2.5,
    )

    result = reporter.report_activity({"event_type": "validation", "title": "Tests passed"})

    assert result == {"operation": "created"}
    assert captured["url"] == "http://cga.local/api/project/work-briefing/activity"
    assert captured["headers"]["Authorization"] == "Bearer edge-token"
    assert captured["headers"]["X-project-id"] == "ADC123"
    assert captured["timeout"] == 2.5
    assert '"project_id": "ADC123"' in captured["body"]
    assert '"workspace_name": "ADC"' in captured["body"]


def test_report_activity_returns_empty_dict_for_empty_response(monkeypatch) -> None:
    class EmptyResponse:
        def __enter__(self):
            return self

        def __exit__(self, exc_type, exc, traceback):
            return False

        def read(self) -> bytes:
            return b""

    monkeypatch.setattr("backend.contextgraph_reporter.request.urlopen", lambda *_args, **_kwargs: EmptyResponse())
    reporter = ContextGraphWorkBriefingReporter(
        api_url="http://cga.local/api/project/work-briefing/activity",
        project_id="ADC123",
        token="edge-token",
        workspace_name="ADC",
    )

    assert reporter.report_activity({"event_type": "validation", "title": "Tests passed"}) == {}


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


def test_startup_skips_reporting_when_reporter_is_not_configured(monkeypatch) -> None:
    monkeypatch.setattr(main_module, "_contextgraph_reporter", None)

    with TestClient(main_module.app) as client:
        response = client.get("/health")

    assert response.status_code == 200


def test_startup_swallows_reporting_failure(monkeypatch) -> None:
    class FailingReporter:
        def report_activity(self, payload: dict) -> dict:
            raise RuntimeError("CGA unavailable")

    monkeypatch.setattr(main_module, "_contextgraph_reporter", FailingReporter())

    with TestClient(main_module.app) as client:
        response = client.get("/health")

    assert response.status_code == 200
