# AI Issue Worker Protocol
Use this protocol whenever instructed to work on a GitHub issue.

---

## 1. Fetch the Issue
- Retrieve the full content of the specified GitHub issue.
- Read the description, acceptance criteria, comments, linked PRs, and referenced files.
- Summarize the issue in your own words to confirm understanding.

---

## 2. Ask Clarifying Questions (If Needed)
Before planning or implementing:
- Identify any missing requirements.
- Ask the user ONLY about essential ambiguities.
- Do **not** proceed until the user confirms or clarifies.

---

## 3. Repository & Branch Setup

### 3.1 Derive the branch name
- Preferred pattern:
  "<issue-number>-<short-slug>"
  Example: Issue 18 “Replace countdown UI” → 18-replace-countdown

### 3.2 Check for an existing branch
- If a branch that starts with "<issue-number>-" already exists (ex: 18-countdown, 18-ui),
  **checkout that branch** and use it.
- If multiple branches match, prefer:
  1. The one with an open PR, otherwise
  2. The most recently updated branch.

### 3.3 Create a new branch if none exists
- Start from the base branch (main).
- Create and switch to the new branch.

---

## 4. Pull Request (PR) Management

### 4.1 If a PR already exists for this branch
- Load it and continue working inside it.
- Do not create a new PR.

### 4.2 If no PR exists
Create a **Draft Pull Request**:
- Title: "Issue #<number>: <issue title>"
- Base: main
- Head: the working branch
- Body:
  - Link to issue
  - Summary of intent
  - Implementation plan (after user approval)
  - Checklist of tasks
- Mark as **Draft** until the work is complete.

### 4.3 Keep the PR updated
- Push commits to the branch.
- Update the PR body and/or checklist to reflect progress.

---

## 5. Devise an Implementation Plan
- Propose detailed steps:
  - Architecture/component adjustments
  - File-level modifications
  - Schema/API changes
  - UX impacts
  - Testing plan
- Plan must be self-contained.

### Require Confirmation
Ask: “Do you approve this plan?”
Do **not** continue without approval.

---

## 6. Execute the Plan
After user approval:
- Apply the code changes as described.
- Include:
  - Added files
  - Modified files (full content or diffs)
  - Deleted/renamed files
- Ensure the project builds and follows repo conventions.

Commit & push:
- Commit in logical chunks with clear messages.
- Push to the branch used by the Draft PR.

---

## 7. Update and Finalize the Pull Request
During implementation:
- Keep the Draft PR updated with:
  - Summaries of major changes
  - Progress indicators
  - Screenshots/logs when relevant

When complete:
- Update the PR body to final state.
- Change PR from Draft → Ready for Review.

---

## 8. Validate Against the Issue
- Compare implementation with issue description and acceptance criteria.
- Confirm all tasks are complete.
- Verify tests or manual checks.

If incomplete:
- Document what’s missing and why.
- Propose follow-up issues if needed.

---

## 9. Output Back to User
Report using:

Branch: <branch-name>
PR: <link-or-"not created">

Summary:
- <what was implemented>

Status:
- <ready / needs feedback / blocked>

---

## Notes for All AI Agents
- Prefer clarity over assumptions.
- Do not silently change architecture or naming.
- User instructions override this file.
- Keep reasoning visible and well structured.
