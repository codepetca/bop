# AI Issue Author Protocol
Use this protocol whenever you are asked to **create or refine a GitHub issue** so that another AI (or human) can easily pick it up and implement it later.

Your goal: turn a vague idea, bug report, or feature request into a **clear, self-contained, implementation-ready issue**.

**Expected output:** When asked to create or refine an issue, return:
- A title following the format in Section 3.
- The full issue body using the template in Section 2.
- Suggested labels (if known) and a short branch slug for the implementer.

---

## 1. When to Create an Issue
Create or update a GitHub issue when:
- A bug, regression, or UX problem is identified.
- A new feature, refactor, or cleanup task is needed.
- A follow-up or spin-off task appears during work on another issue or PR.

If the user just wants a quick note, you can still follow this template but keep it short.

---

## 2. Required Output Format (Issue Body Template)

When you create an issue, **always** structure the body like this:

```md
## Summary
<1–3 sentences explaining what needs to be done, in plain language.>

## Background / Context
<Why this is needed. Where it was discovered. Links to PRs, issues, or discussions. Screenshots if applicable.>

## Problem Statement
<What is wrong or missing today? Describe from the user’s or system’s perspective.>

## Steps to Reproduce (for bugs)
1. <Step-by-step actions to trigger the issue>
2. <Include data or settings if relevant>
**Actual result:** <What happens today?>

## Environment / Versions (for bugs)
- Device/OS: <e.g., Apple Watch Series 9, watchOS 10.4>
- App/build: <e.g., TestFlight 1.2.3 (123) or commit SHA>
- Other context: <network state, peripherals, locale, etc.>

## Requirements / Acceptance Criteria
- [ ] <Concrete, verifiable behavior 1>
- [ ] <Concrete, verifiable behavior 2>
- [ ] <Edge case or variant, if applicable>
- [ ] <Any UX or performance expectations>

**Note:** When creating issues, reference feature IDs from `.ai/features.json` if applicable.
This helps track completion across the structured feature inventory and links issues to specific features.

## Scope
**In scope**
- <List what this issue should cover>

**Out of scope**
- <List what is explicitly NOT part of this issue but might be future work>

## Implementation Notes (Optional but Recommended)
<Non-binding hints for the implementer. For example:>
- Relevant files / modules: `<path/to/file.swift>`, `<src/components/...>`
- Data models or APIs involved
- Known constraints (platform, performance, backwards compatibility)
- Ideas for a possible approach (without over-specifying if not needed)

## Testing Plan
- [ ] <Unit test or snapshot test to add/update>
- [ ] <Manual test steps for the feature/bug>
- [ ] <Device/OS combinations to verify, if relevant (e.g., watchOS versions, iOS versions)>

## Risks / Open Questions
- <List any uncertainties, trade-offs, or dependencies>
- <Questions you want the future implementer or reviewer to think about>

## References
- Issue/PR links: <#123, #456, etc.>
- Design docs / ADRs:
- Screenshots / recordings:
```

---

## 3. Title & Labels

### 3.1 Title Format
Use a short, specific title that starts with the type of work:

- `fix: <short description>`
- `feat: <short description>`
- `chore: <short description>`
- `refactor: <short description>`
- `docs: <short description>`

Examples:
- `feat: replace countdown UI with 3-2-1-Go text`
- `fix: workout session not ending on watch when app closes`

### 3.2 Labels (if you are allowed to specify them)
If repo conventions are known, apply appropriate labels, e.g.:

- `type:bug`, `type:feature`, `type:refactor`
- `platform:watchOS`, `platform:iOS`, `platform:web`
- `priority:high`, `priority:medium`, `priority:low`

If you don’t know the exact labels, mention them in the issue body under **Background / Context** (e.g., “Suggested labels: type:bug, platform:watchOS”).

---

## 4. How to Extract Info From the Conversation

When the user asks you to “create an issue”:

1. **Re-read the conversation or bug description.**
2. Extract:
   - What is happening now (current behavior)
   - What should happen instead (desired behavior)
   - Any environment details (device/OS, browser, version, etc.)
   - Any designs, screenshots, or logs mentioned
3. Fill in all sections of the template as much as possible.
4. If crucial details are missing (e.g., expected behavior is unclear), add a short note under **Risks / Open Questions** instead of blocking issue creation.

Only ask the user follow-up questions if:
- The missing info makes the issue impossible to understand or act on, **and**
- You cannot reasonably guess or write it as an explicit open question.

---

## 5. Quality Bar for a “Good Issue”

A “good” issue should:
- Be understandable **without rereading the original chat**.
- Allow an AI using `issue-worker.md` to:
  - Derive a branch name
  - Devise an implementation plan
  - Implement and validate the change
- Have acceptance criteria that are:
  - Specific
  - Testable
  - Closely tied to the problem statement

Use this check before finalizing:
- Can another engineer (or AI) implement this issue with no extra context?
- Can they write tests directly from the **Requirements / Acceptance Criteria** section?
- Are the trade-offs or unknowns clearly documented?

If “no”, improve the issue by:
- Tightening the **Problem Statement**
- Expanding **Requirements / Acceptance Criteria**
- Adding one or two key **Implementation Notes**

**Pre-flight before finalizing**
- Acceptance criteria are pass/fail and map to the problem statement.
- Missing info is captured as questions under Risks/Open Questions.
- Suggested labels and a branch slug are included (or noted if unknown).
- Bugs include Steps to Reproduce and Environment/Versions.
- Testing Plan lists both automated and manual checks where reasonable.

---

## 6. Examples (For Yourself, Not to Copy Literally)

### Feature example
```md
## Summary
Replace the busy circular countdown in WristBop with a simple 3-2-1-Go text countdown before each game starts.

## Background / Context
Currently, the pre-game countdown uses a circular progress indicator with multiple text states (“Ready”, “Go”, etc.). This is visually noisy and harder to read quickly on smaller watch faces. We want a minimal, bold text-only countdown that is easy to parse at a glance.

## Problem Statement
The existing countdown UI:
- Is overly animated and can distract from gameplay.
- Uses words instead of a clear numeric countdown.
- Is harder to read on smaller Apple Watch screens.

## Requirements / Acceptance Criteria
- [ ] When a game starts, show a full-screen countdown sequence: "3" → "2" → "1" → "Go!".
- [ ] Each step should be visible for ~1 second.
- [ ] Text should be centered horizontally and vertically and legible on all supported watch sizes.
- [ ] Old circular countdown graphics and animations are no longer visible anywhere.
- [ ] After "Go!", the game transitions immediately into the first prompt.

## Scope
**In scope**
- Replacing the countdown UI component.
- Adjusting view logic/state management for pre-game countdown.

**Out of scope**
- Changing in-game prompts or timing logic after the countdown finishes.
- Score logic or analytics changes.

## Implementation Notes
- Likely involves updating the pre-game view in `WristBop Watch App/ContentView.swift` (or the dedicated countdown view if one exists).
- SwiftUI text-based view with simple `withAnimation` transitions should be sufficient.
- Consider extracting the countdown into a reusable `CountdownView`.

## Testing Plan
- [ ] Manual: Start a game multiple times and verify the countdown appears as 3 → 2 → 1 → Go.
- [ ] Manual: Verify behavior on at least two watch sizes (e.g., 41mm and 45mm simulators).
- [ ] Automated: If feasible, add a view snapshot or state test for the countdown sequence.

## Risks / Open Questions
- Do we need localization for "Go!"?
- Should timings be configurable for future difficulty settings?

## References
- Related discussions: <link to Slack/Discord/Docs if available>
- Design reference: <Figma or screenshot if available>
```

### Bug example
```md
## Summary
Workout session does not end on watch when the app is closed during play.

## Background / Context
Reported after QA force-quit the watch app mid-game. Session stays active and keeps the timer running, leading to incorrect workout totals. Suggested labels: type:bug, platform:watchOS, priority:medium.

## Problem Statement
When the watch app is terminated during an active workout session, the workout continues in the background instead of ending gracefully and saving results.

## Steps to Reproduce (for bugs)
1. Start a game on Apple Watch.
2. Play until the workout session is active.
3. Press the side button, swipe up, and force quit the app.
**Actual result:** The workout session keeps running; heart rate and time continue to accrue.

## Environment / Versions (for bugs)
- Device/OS: Apple Watch Series 9, watchOS 10.4
- App/build: TestFlight 1.2.3 (123)
- Other context: Always-on display enabled

## Requirements / Acceptance Criteria
- [ ] If the app is terminated while a session is active, the workout ends immediately.
- [ ] Workout data saves without errors or partial entries.
- [ ] Next app launch shows no active session and allows starting a new one.
- [ ] No background workout continues after app termination.

## Scope
**In scope**
- Handling app termination during an active workout.
- Ensuring data persistence for ended sessions.

**Out of scope**
- Changes to scoring or prompt timing.
- UI changes during normal in-app session endings.

## Implementation Notes
- Likely in watchOS target: workout session lifecycle in `WristBop Watch App/...`.
- Ensure `HKWorkoutSession` end is triggered on termination hooks.
- Consider background task limits for cleanup.

## Testing Plan
- [ ] Manual: Reproduce the termination sequence; confirm session stops and data saves.
- [ ] Automated: Unit or integration test for workout session lifecycle where feasible.
- [ ] Manual: Verify on at least two watch sizes (41mm and 45mm) and watchOS 10.4+.

## Risks / Open Questions
- Are there system constraints that delay `HKWorkoutSession` end callbacks?
- Do we need to handle interrupted network requests when saving data?

## References
- Issue/PR links: <if any>
- Design docs / ADRs:
- Screenshots / recordings: <if available>
```

---

## 7. When Running as an “Issue Author” Agent

If instructed, for example:

> “Create a GitHub issue for this bug using issue-author.md”

You should:
1. Load this file.
2. Extract the problem, desired behavior, and context from the conversation or description.
3. Generate:
   - A clear **Title**.
   - A complete **Issue Body** using the template in Section 2.
4. Present the issue back to the user in markdown form.
5. If asked, also provide:
   - Suggested labels
   - A short branch name slug (for future use by issue-worker.md).
