from __future__ import annotations

import json
import os
from typing import Any
from urllib import request


def _derive_briefing_api_url(mcp_server_url: str) -> str:
    cleaned = (mcp_server_url or "").strip().rstrip("/")
    if not cleaned:
        return ""
    for suffix in ("/mcp/sse", "/mcp/messages", "/mcp"):
        if cleaned.endswith(suffix):
            return cleaned[: -len(suffix)] + "/api/project/work-briefing/activity"
    return cleaned + "/api/project/work-briefing/activity"


class ContextGraphWorkBriefingReporter:
    def __init__(
        self,
        api_url: str,
        project_id: str,
        token: str,
        workspace_name: str,
        timeout_sec: float = 5.0,
    ) -> None:
        self.api_url = api_url.strip()
        self.project_id = project_id.strip()
        self.token = token.strip()
        self.workspace_name = workspace_name.strip()
        self.timeout_sec = timeout_sec

    @classmethod
    def from_env(cls, workspace_name: str) -> "ContextGraphWorkBriefingReporter | None":
        api_url = (os.environ.get("CONTEXTGRAPH_BRIEFING_API_URL") or "").strip()
        if not api_url:
            api_url = _derive_briefing_api_url(os.environ.get("CONTEXTGRAPH_MCP_SERVER_URL", ""))
        if not api_url and os.environ.get("CONTEXTGRAPH_UPSTREAM_URL"):
            api_url = os.environ["CONTEXTGRAPH_UPSTREAM_URL"].strip().rstrip("/") + "/api/project/work-briefing/activity"

        project_id = (os.environ.get("CONTEXTGRAPH_PROJECT_ID") or "").strip()
        token = (
            (os.environ.get("CONTEXTGRAPH_EDGE_AGENT_TOKEN") or "").strip()
            or (os.environ.get("CONTEXTGRAPH_MCP_TOKEN") or "").strip()
        )
        if not api_url or not project_id or not token:
            return None
        return cls(
            api_url=api_url,
            project_id=project_id,
            token=token,
            workspace_name=workspace_name,
        )

    def report_activity(self, payload: dict[str, Any]) -> dict[str, Any]:
        body = dict(payload)
        body.setdefault("project_id", self.project_id)
        body.setdefault("workspace_name", self.workspace_name)
        raw = json.dumps(body, ensure_ascii=True).encode("utf-8")
        http_request = request.Request(
            self.api_url,
            data=raw,
            method="POST",
            headers={
                "Authorization": f"Bearer {self.token}",
                "Content-Type": "application/json",
                "X-Project-ID": self.project_id,
            },
        )
        with request.urlopen(http_request, timeout=self.timeout_sec) as response:
            payload_bytes = response.read()
        if not payload_bytes:
            return {}
        return json.loads(payload_bytes.decode("utf-8"))
