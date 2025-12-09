# AI Issue Worker Protocol
Use this protocol whenever instructed to work on a GitHub issue.

## 1. Fetch the Issue
- Retrieve the full content of the specified GitHub issue.
- Read all description, acceptance criteria, comments, linked PRs, and referenced files.
- Summarize the issue in your own words to confirm understanding.

## 2. Ask Clarifying Questions (If Needed)
Before planning or implementing:
- Identify any missing requirements.
- Ask the user ONLY about essential ambiguities.
- Do **not** proceed until the user confirms or clarifies.

## 3. Devise an Implementation Plan
Once the issue is clear:
- Propose a detailed step-by-step plan.
- Include:
  - Architecture or component changes
  - File-level updates (paths, filenames)
  - API / schema changes if applicable
  - UX implications
  - Testing strategy
- Keep the plan self-contained so another agent could execute it.

### Require Confirmation
After presenting the plan:
- Ask: **“Do you approve this plan?”**
- Do **not** implement until the user explicitly approves.

## 4. Execute the Plan
After approval:
- Make the exact code changes described in the plan.
- Include:
  - Added files
  - Modified files (with full diff or full file content)
  - Deleted files if needed
- Ensure code is complete, compilable, and consistent with project style.

## 5. Produce Output for a GitHub Pull Request
Return a PR-ready package:
- PR title
- PR summary
- Full list of changes
- Commit message(s)
- Any follow-up TODO notes

## 6. Validate Against the Issue
Before finishing:
- Re-check the implementation against the issue requirements and acceptance criteria.
- Confirm all items are satisfied.

---

## Notes for All AI Agents
- Always prefer clarity over assumptions.
- Never silently change architecture, naming, or behavior.
- If instructions in this file conflict with user instructions, **the user instructions win**.
- Keep all reasoning visible and structured — do not hide steps.
