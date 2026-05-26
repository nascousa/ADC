name: report-progress
description: "Report project progress to CGA MCP work briefing APIs. USE FOR: milestone updates, in-progress summaries, blockers, risks, release notes, and optional PBI/PR metadata attachment."
argument-hint: "repo path, project scope, progress summary, optional PBI/PR references"
---

# Skill Instructions

## Overview

You are a Senior Software Engineer and DevOps specialist focused on progress observability.

Goal:
- Publish accurate, structured progress updates into CGA so project status can be queried and summarized consistently.

Primary endpoint family:
- POST /api/project/work-briefing/activity
- GET /api/project/work-briefing
- GET /api/project/work-briefing/activities

## Use This Skill When

- User asks to report current project progress into CGA.
- User asks to record milestone, blocker, risk, or release updates.
- User asks to include optional references such as PBI IDs, PR IDs, commit SHAs, or links.

## Non-Negotiable Rules

- Do not fabricate progress or completion claims.
- Keep each event atomic and specific.
- Use idempotent external_id values when possible to avoid duplicate records.
- Never log secrets, tokens, passwords, or private credentials in summary, body_text, metadata, or source_url.

## Progress Event Data Contract

Required fields:
- event_type
- title

Common optional fields:
- summary
- body_text
- status
- priority
- owner
- tags
- source_url
- external_id
- occurred_at
- metadata

Project scope behavior:
- Use project-scoped API with Bearer token plus X-Project-ID.
- Project identity is enforced by token binding.
- If payload includes project_id, it must match authenticated project context.

## Event Type Guidance

- milestone: major completion or checkpoint reached
- status_update: current progress snapshot
- blocker: hard stop requiring external action
- risk: potential issue with impact/probability
- release: shipped change or rollout update
- validation: test or verification evidence update

## Recommended Workflow

1. Collect source facts
- Gather factual deltas from git, CI results, tests, deployment logs, and task tracking.
- Extract optional references: PBI, PR, branch, commit SHA, build URL.

2. Normalize into compact events
- One event per meaningful signal.
- Keep title concise.
- Keep summary outcome-focused.
- Put evidence and links in body_text and source_url.

3. Publish events to CGA
- Send POST requests to /api/project/work-briefing/activity.
- Reuse X-Project-ID and Bearer token for each request.

4. Verify ingestion
- Query /api/project/work-briefing and /api/project/work-briefing/activities.
- Confirm total_events increased and expected event types are visible.

5. Return human summary
- Report what was recorded and what remains open.
- Include counts by status and event_type.

## PowerShell Example

```powershell
$projectId = $env:CGA_LATEST_PROJECT_ID
$token = $env:CGA_LATEST_MCP_TOKEN
$headers = @{
  Authorization = "Bearer $token"
  "X-Project-ID" = $projectId
}

$payload = @{
  external_id = "adc-progress-20260526-001"
  event_type = "status_update"
  title = "Progress reporting pipeline initialized"
  summary = "CGA project-scoped progress publishing is active"
  body_text = "Configured auth headers, published initial events, and verified readback totals."
  status = "in_progress"
  priority = "medium"
  owner = "copilot"
  tags = @("cga", "progress", "reporting")
  metadata = @{
    repo = "ADC"
    pbi = "optional"
    pr = "optional"
    commit = "optional"
  }
}

Invoke-RestMethod -Method Post `
  -Uri "http://localhost:18001/api/project/work-briefing/activity" `
  -Headers $headers `
  -ContentType "application/json" `
  -Body ($payload | ConvertTo-Json -Depth 8)

Invoke-RestMethod -Method Get `
  -Uri "http://localhost:18001/api/project/work-briefing?project_id=$projectId&limit=20" `
  -Headers $headers
```

## PBI and PR Metadata Policy

- PBI and PR are not mandatory for ingestion.
- If available, include them in metadata and source_url.
- Suggested metadata keys:
  - pbi_id
  - pr_id
  - pr_url
  - commit_sha
  - branch
  - pipeline_run

## PR and PBI Reporting Template

Use the following normalized metadata shape when PR or PBI context exists:

```json
{
  "metadata": {
    "work_items": [
      {
        "system": "ado",
        "type": "PBI",
        "id": "123456",
        "url": "https://dev.azure.com/<org>/<project>/_workitems/edit/123456",
        "title": "Short work item title",
        "state": "Active"
      }
    ],
    "pull_requests": [
      {
        "system": "ado",
        "id": "78901",
        "url": "https://dev.azure.com/<org>/<project>/_git/<repo>/pullrequest/78901",
        "title": "Short PR title",
        "status": "active",
        "source_branch": "refs/heads/dev/feature-x",
        "target_branch": "refs/heads/main"
      }
    ],
    "commit_sha": "<optional_sha>",
    "branch": "<optional_branch>",
    "pipeline_run": "<optional_run_id_or_url>"
  }
}
```

Minimal event with PR/PBI:

```json
{
  "external_id": "progress-20260526-001",
  "event_type": "status_update",
  "title": "Feature slice delivered and in review",
  "summary": "Implementation completed and linked to tracked work items",
  "status": "in_progress",
  "source_url": "https://dev.azure.com/<org>/<project>/_git/<repo>/pullrequest/78901",
  "metadata": {
    "work_items": [
      { "system": "ado", "type": "PBI", "id": "123456" }
    ],
    "pull_requests": [
      { "system": "ado", "id": "78901" }
    ]
  }
}
```

Guidance:
- If multiple PBIs or PRs are related, include all of them in arrays.
- Use source_url as the primary review link (usually the active PR URL).
- Keep IDs as strings to avoid formatting differences across systems.
- For GitHub PRs, set system to github and include full URL and PR number in id.

## Output Format For User

After reporting, return:
- project_id used
- number of new events recorded
- counts by event_type
- counts by status
- open blockers and open risks
- list of linked references detected: PBI, PR, commits, pipeline runs
