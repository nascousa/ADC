---
name: ado-ticket-creator
description: "Create Azure DevOps work items for completed work broken into logical steps. USE FOR: decompose completed features into PBIs, create linked PRs for each PBI, batch-ticket multi-step deliverables, link work items to pull requests, send PR approval requests to Teams."
argument-hint: "[completed work description] [optional: parent feature ID]"
---

# Skill Instructions

## Overview

You are a Senior Software Engineer and DevOps specialist.

**Goal**: Decompose completed work into logical, independently deliverable steps, each mapped to a PBI and (if code-related) a linked PR.

**Process**:
1. Analyze and propose a breakdown as a numbered list of functional steps
2. Create work items and PRs step-by-step in sequence
3. Confirm completion before moving to the next step

**Tooling**: Use Azure DevOps CLI for work item creation; use git only when repository changes are actually required.

## Workflow: Create Work Items from Decomposed Steps

### Step-by-Step Procedure

1. **Analyze & Propose**: Show me the proposed breakdown as a numbered list of logical steps before creating any work items.
2. **Create PBI**: For each step, create an Azure DevOps Product Backlog Item (PBI) with the details below.
3. **Create Branch & PR** (if code changes): For code-related steps only, create a local git branch, push it, create a PR, and link the PR to the PBI.
4. **Confirm & Move Forward**: Do not move to the next step until the current item is fully set up:
   - PBI only for non-code changes
   - PBI + branch + PR for code changes

### PBI Details

Work Item field values:
- **Work Item Type**: Product Backlog Item
- **State**: New
- **Area**: Database Systems\Azure PG\Orcas SWE\Orcas Air Gapped Cloud Eng Team
- **Iteration**: Database Systems\OrcaSQL\AGC\Planned
- **Tags**: IcM Automation, USSec
- **Assigned To**: nasco@microsoft.com
- **Title**: Concise and specific to the single functional change
- **Description**: Detailed summary of purpose, scope, and expected outcome

### PR Requirements (for code-change steps)

- Create PR **immediately** after branch push
- Link the PR to the corresponding PBI
- **PR title**: Concise and specific to that single functional change
- **PR description** must include:
  - Summary
  - Scope
  - Validation approach
  - Related Work Item
- Confirm PR creation by returning **PR ID, title, and URL** before proceeding to the next step

### Branching Rules

- **Create a branch only if** the step requires actual repository changes:
  - Code updates
  - Scripts
  - IaC (Infrastructure as Code)
  - Tests
  - Configuration files
  - Documentation
- **Do NOT create a branch for** Azure-only changes:
  - Portal configuration
  - NSP (Network Security Policy)
  - RBAC role assignments
  - Azure Policy updates
  - Diagnostics settings
  - Other resource-side changes
- **Branch naming**: `nasco/<workItemId>-<short-kebab-summary>`
- **Verify** the branch exists before proceeding to the next item

### Work Item Description Formatting

- Do **NOT** use Markdown-style discussion comments for detailed content
- Do **NOT** use `--discussion` with Markdown headings (`##`, `###`)
- For detailed notes, use Azure DevOps CLI with `--fields "System.History=<html...>"` to render correctly in work item UI
- Use **HTML formatting** for detailed notes:
  - `<p>` for paragraphs
  - `<strong>` for section labels
  - `<ul><li>...</li></ul>` for bullet lists
  - `<br>` only when needed
- Structure sections:
  - Summary
  - Changes completed
  - Verified state or Current findings
  - Result or Remaining work
  - Related items

### Planning Constraints

- Prefer **small, focused items** that map cleanly to separate PRs when code changes are involved
- Follow the repository governance rule: **one work item maps to one PR** for code changes
- For larger initiatives, create one parent **Feature** and attach child PBIs under it
- Prefer parent Feature + child PBIs over one large ticket with multiple tasks (unless explicitly requested otherwise)

### Completion & Output

After execution, provide a summary:
- Parent item ID and title (if created)
- Each child PBI: ID, title, and link
- Each child PR: ID, title, and link

Then offer to notify the Release Approvals Teams channel (see "Workflow: Notify Teams" below).



---

## Workflow: Notify Teams of PR Approvals

### Step-by-Step Procedure

1. **Fetch Active PRs**: Retrieve all "Active" pull requests created by you from the current Azure DevOps project. Present them as a numbered list with:
   - PR ID
   - PR Title
   - PR URL

2. **User Selection**: Prompt user to select one or more PR numbers to be shared.

3. **Format Notification Message**: For each selected PR, generate a professional approval request:
   - **Format**: Plain text inside a Markdown code block (to avoid auto-formatting when copying)
   - **Content per PR**:
     ```
     * Title of the PR
       - Direct Link
       - Action Required: Please review and approve.
     ```
   - **Constraint**: Do NOT use emojis or icons

4. **Open Teams Channel**: Provide a Windows PowerShell command using `Start-Process` to open the Release Approvals channel:
   ```powershell
   Start-Process "https://teams.microsoft.com/l/channel/19%3AxGjPLxyiPSlkjf9fcclKlinVoiUSSqwYmX9PE7jYtp01%40thread.tacv2/%F0%9F%9A%80%20Release%20Approvals?groupId=00b71cac-9582-4820-b432-97ceb4232c3d&tenantId=72f988bf-86f1-41af-91ab-2d7cd011db47&ngc=true&allowXTenantAccess=true"
   ```

### Important

Ensure the PowerShell command and the notification text are clearly separated so the user can copy the text first, then run the command.
