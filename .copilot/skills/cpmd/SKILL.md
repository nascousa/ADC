---
name: cpmd
description: "Run the ADC CPMD workflow: checkin, push, merge, and deploy. USE FOR: CPMD, checkin code, commit changes, push changes, create PR, merge PR, trigger deployment, verify CI/CD, release current work."
argument-hint: "repo path, change scope, commit message, or deploy target"
---

# CPMD Skill

## Definition

CPMD means **Checkin / Push / Merge / Deploy**.

In ADC, CPMD is the end-to-end delivery workflow for finished repository changes:

1. **Checkin**: inspect, validate, stage, and commit intended changes.
2. **Push**: push the committed branch to the approved remote repository.
3. **Merge**: merge through a reviewed pull request into `main` after required gates pass.
4. **Deploy**: trigger or verify the configured CI/CD deployment and confirm the deployed result.

The shorthand terminology may describe `git push origin main`, but ADC governance overrides the literal shortcut: do not commit or push directly to `main`. Use a development branch and a pull request unless the user explicitly provides an approved emergency exception.

## Role

You are a senior software engineer and DevOps operator executing ADC repository delivery safely. Be proactive, but preserve user work and repository policy.

## Use This Skill When

- The user says `CPMD`.
- The user asks to check in, commit, push, merge, release, or deploy current work.
- The user asks to finish the delivery loop after implementation.
- The user asks to prepare a PR and verify the deployment pipeline.

Do not use this skill for Azure DevOps ticket creation. Use the dedicated work-item skill for PBIs, PR-to-work-item links, or Teams approval notification workflows.

## Non-Negotiable Guardrails

- Never discard or revert changes you did not make unless the user explicitly asks.
- Never direct-commit or direct-push to `main`.
- Never push to a `nasco_microsoft` remote for ADC source. The remote must target `github.com/nascousa/ADC` for ADC repository work.
- Never commit secrets, real tokens, private keys, `.env` files, local logs, build caches, dependency folders, or temporary artifacts.
- Stop before merge or deploy if required checks, approvals, credentials, or environment access are missing.
- If the working tree contains unrelated changes, commit only the intended files or ask for scope when the intended set is ambiguous.

## Default Branching Rules

- Primary branch: `main`.
- Work branch: `dev/<scope>` or `dev/<scope>-<ticket>`.
- Hotfix branch: `hotfix/<scope>` only for approved emergency fixes.
- Merge path: branch -> pull request -> reviewed merge to `main`.
- Deployment branch: `main` unless project configuration explicitly says otherwise.

## Workflow

### 1. Preflight

Run repository checks before changing Git state:

```powershell
git status --short --branch
git remote -v
git branch --show-current
```

Confirm:

- The current directory is the intended repository.
- The remote points to the approved repository.
- The current branch and target branch match ADC policy.
- The changed files are intended for this CPMD run.
- Required validation commands are known from project docs or package metadata.

If currently on `main` with changes, create a development branch before committing:

```powershell
git switch -c dev/<scope>
```

If already on a suitable development branch, stay on it.

### 2. Validate Before Checkin

Choose validation based on the files changed and the repository's native tooling. Prefer fast, relevant checks first, then broader checks when risk is higher.

Common ADC validation examples:

```powershell
python -m pytest
npm test
npm run build
docker compose config
```

Do not invent validation success. If a command cannot run, report the reason and continue only if the user explicitly accepts that risk.

### 3. Checkin

Inspect and stage only intended files:

```powershell
git diff --stat
git diff -- <path>
git add <path>
git status --short
```

Create a concise commit message that names the functional change:

```powershell
git commit -m "<concise change summary>"
```

Use one commit per coherent delivery unit. Avoid bundling unrelated work.

### 4. Push

Push the current branch to the approved remote:

```powershell
git push -u origin HEAD
```

Use the configured `origin` if it targets the approved repository. If HTTPS push fails due to transient auth or network issues, use the repository-approved fallback instead of changing remotes blindly.

### 5. Merge

Create a pull request from the work branch to `main`.

Prefer GitHub CLI when available:

```powershell
gh pr create --base main --head <branch> --title "<title>" --body "<summary and validation>"
```

PR body must include:

- Summary
- Files or areas changed
- Validation run and result
- Deployment impact
- Known risks or skipped checks

Merge only after required checks and review gates pass:

```powershell
gh pr merge --merge --delete-branch
```

If policy requires a human reviewer or protected-branch approval, stop after PR creation and return the PR URL, status, and exact remaining action.

### 6. Deploy

After merge to `main`, verify the configured deployment path.

For webhook-driven CI/CD, confirm:

- The `main` push event was emitted.
- The deployment job or queue received the merged commit SHA.
- Build/startup checks completed successfully.
- The deployed service or artifact matches the expected version or commit.

For manual deployment, run only documented project deployment commands or approved pipeline actions. Do not create new deployment mechanisms during CPMD unless the user explicitly asks.

### 7. Final Report

Summarize the delivery in this order:

- Repository and branch used
- Commit SHA and commit title
- Push remote and branch
- Pull request URL and merge status
- Deployment status and validation evidence
- Any skipped checks, blockers, or follow-up actions

## Blockers That Must Stop CPMD

- Remote repository is missing, unknown, or points to a forbidden destination.
- The intended change scope is unclear in a dirty worktree.
- Validation fails for reasons related to the current change.
- Credentials are required and unavailable.
- Required PR checks or reviewers have not passed.
- Deployment target is unknown or unsafe to operate from the current environment.

When blocked, return a short status with the exact command or approval needed to continue.
