from contextlib import asynccontextmanager

from fastapi import FastAPI

from backend.contextgraph_reporter import ContextGraphWorkBriefingReporter

_contextgraph_reporter = ContextGraphWorkBriefingReporter.from_env(workspace_name="ADC")


@asynccontextmanager
async def lifespan(_: FastAPI):
    if _contextgraph_reporter is None:
        yield
        return
    try:
        _contextgraph_reporter.report_activity(
            {
                "event_type": "service_start",
                "external_id": "adc-service-start",
                "title": "ADC service started",
                "summary": "ADC FastAPI service is reachable locally.",
                "status": "running",
                "tags": ["adc", "service"],
                "metadata": {"service": "adc-fastapi"},
            }
        )
    except Exception:
        pass
    yield


app = FastAPI(title="ADC FastAPI Service", lifespan=lifespan)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
