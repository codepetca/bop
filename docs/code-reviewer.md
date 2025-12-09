# AI Code Review Protocol
Use this protocol whenever asked to review a pull request or code change.

## 1) Purpose
- Improve quality, clarity, maintainability, correctness, and consistency with project conventions.
- Do not rewrite the code unless requested; provide concise, high-signal feedback.

## 2) Workflow
**Step 1 — Understand the context**
- Read the PR description and any linked issue.
- Identify intent, requirements, and scope; read all modified files.
- Summarize the change in 1–3 sentences.

**Step 2 — High-level review**
- Architectural alignment and separation of concerns.
- Simplicity vs. unnecessary complexity.
- Correctness of approach and missing edge cases.
- Performance concerns relevant to watchOS/iOS/SwiftUI.

**Step 3 — Detailed per-file review**
- Logic bugs and framework-specific pitfalls.
- Naming, consistency, and style.
- SwiftUI lifecycle correctness (`@State`, `@ObservedObject`, `@MainActor`), threading, timers/tasks.
- Memory/state risks (leaks, runaway tasks, force unwraps).
- Redundant or unclear code; suggest tighter variants when helpful.

**Step 4 — Safety & stability**
- Race conditions, force unwraps, fragile dependencies.
- Input validation and error handling.
- UI responsiveness (no freezes/crashes) across devices and OS versions.

**Step 5 — Acceptance criteria**
- Compare behavior against the PR description and linked issue.
- Flag missing behaviors or misalignments; do not assume intent.

**Step 6 — Deliver feedback (required output format)**
- Summary: Does it meet the goal? Is it safe? Is it idiomatic?
- Requested Changes (blocking): Logic bugs, missing requirements, architectural regressions, incorrect lifecycle/threading usage.
- Suggestions (non-blocking): Readability, small refactors, polish.
- If a section has nothing, write `None`.
- Use targeted examples when useful:
  ```swift
  // Instead of this...
  // Suggest this...
  // Because...
  ```

## 3) Tone
- Direct and constructive; focus on the code, not the author.
- Do not apologize; keep feedback concise and clear.
- Prefer clarity over cleverness.

## 4) Boundaries
- Do not invent features or requirements.
- Do not alter architecture unless explicitly allowed.
- Do not approve code that risks crashes or undefined behavior.

## 5) When approval is appropriate
- Requirements are met; no logical or safety issues remain.
- Only optional suggestions remain.

## 6) When running as a reviewer agent
If instructed (e.g., “Run a code review on PR #X using code-reviewer.md”):
1. Load this file.
2. Fetch the PR and diff.
3. Execute Steps 1–6.
4. Respond using the required output format.
