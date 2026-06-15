---
name: report-progress
description: "Report project progress and change information to CGA through CGA-Relay work briefing tools. USE FOR: milestone updates, in-progress summaries, blockers, risks, release notes, validation evidence, and optional PBI/PR metadata attachment."
argument-hint: "repo path, project scope, progress summary, optional PBI/PR references"
---

# Skill Instructions

## Overview

You are a Senior Software Engineer and DevOps specialist focused on progress observability.

Goal:
- Publish accurate, structured progress and change updates into CGA through `cga-relay` so project status can be queried and summarized consistently.

Primary relay path:
- Use the `cga-relay` MCP profile first.
- Publish activity through `workassist_record_activity` or the relay-approved change reporting tool.
- Treat direct CGA HTTP APIs as relay implementation details, not the agent reporting path.

## Use This Skill When

- User asks to report current project progress into CGA.
- User asks to record milestone, blocker, risk, or release updates.
- User asks to include optional references such as PBI IDs, PR IDs, commit SHAs, or links.

## Non-Negotiable Rules

- Do not fabricate progress or completion claims.
- Keep each event atomic and specific.
- Use idempotent external_id values when possible to avoid duplicate records.
- Submit all official progress and change events through `cga-relay`; if relay is unavailable, record blocked change aggregation and retry later.
- Do not POST directly to CGA APIs except when explicitly implementing or debugging `cga-relay` itself.
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
- Use the project-scoped `cga-relay` MCP profile and environment-backed credentials.
- Project identity is enforced by relay/CGA token binding.
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

3. Publish events to CGA through CGA-Relay
- Use the `cga-relay` MCP profile and `workassist_record_activity` or the relay-approved change reporting tool.
- Include project_id only from authenticated project context and never print raw tokens.

4. Verify ingestion
- Query CGA through `cga-relay` retrieval/reporting tools.
- Confirm total_events increased and expected event types are visible.

5. Return human summary
- Report what was recorded and what remains open.
- Include counts by status and event_type.

## CGA-Relay MCP Payload Example

Use this payload shape with `cga-relay` and the `workassist_record_activity` tool. Do not send it directly to CGA HTTP APIs from an agent.

```json
{
  "external_id": "adc-progress-20260526-001",
  "event_type": "status_update",
  "title": "Progress reporting pipeline initialized",
  "summary": "CGA project-scoped progress publishing is active through CGA-Relay",
  "body_text": "Configured relay-backed reporting, published initial events, and verified readback totals.",
  "status": "in_progress",
  "priority": "medium",
  "owner": "copilot",
  "tags": ["cga", "cga-relay", "progress", "reporting"],
  "metadata": {
    "repo": "ADC",
    "pbi": "optional",
    "pr": "optional",
    "commit": "optional"
  }
}
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
