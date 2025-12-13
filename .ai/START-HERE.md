# AI Agent Starting Ritual

**CRITICAL:** Follow this checklist at the start of EVERY session.

---

## 1. Environment Verification (1 min)

```bash
bash scripts/verify-env.sh
```

- [ ] If fails, fix before proceeding
- [ ] If passes, continue

**What this checks:**
- Swift compiler present
- `swift build` succeeds
- `swift test` passes
- Xcode project exists
- `.ai/` directory present

---

## 2. Context Recovery (2-3 min)

```bash
# Read journal (last 5 entries)
tail -60 .ai/JOURNAL.md

# Check recent commits
git log --oneline -10

# Check for recent GitHub events
gh pr list --state closed --limit 5
gh issue list --state closed --limit 5
```

- [ ] Read `.ai/JOURNAL.md` last 5 entries
- [ ] Note any `[GITHUB-EVENT]` entries (human closed PRs/issues)
- [ ] Review recent commits
- [ ] Check current git branch

**What to look for:**
- What was the last session working on?
- Were any PRs merged by human?
- Are there any blockers mentioned?
- What's the current phase?

---

## 3. Feature Status Check (1 min)

```bash
# Quick feature summary
bash scripts/features.sh summary
```

- [ ] Note current phase from features.json `meta.phase`
- [ ] Count passing vs failing features
- [ ] Identify next failing feature to work on

**Output shows:**
- Current phase
- Total/passing/failing counts
- By-phase breakdown
- Next 5 unblocked tasks

---

## 4. Architecture Review (as needed)

- [ ] If first session: Read `architecture.md` fully
- [ ] If working on new component: Read relevant architecture.md section
- [ ] If in doubt about design: Reference architecture.md

**Key documents:**
- `architecture.md` - System design source of truth
- `docs/roadmap.md` - Phase strategy
- `docs/tests.md` - Testing approach

---

## 5. Task Identification (1 min)

**Priority order:**
1. If GitHub issue assigned → Read `docs/issue-worker.md` and follow protocol
2. If PR needs review → Read `docs/code-reviewer.md` and review
3. Otherwise → Check `.ai/features.json` for next `"passes": false` in current phase

**Identify task:**
- [ ] State the feature ID (e.g., "watch-002")
- [ ] State the description
- [ ] Check `blockedBy` array (ensure dependencies pass)
- [ ] Note verification method

```bash
# See next recommended features
bash scripts/features.sh next
```

---

## 6. Plan Before Coding (MANDATORY)

- [ ] State your understanding of the task
- [ ] Reference architecture.md section if applicable
- [ ] Propose implementation approach
- [ ] **WAIT FOR USER APPROVAL**

**Never skip this step.** Proceeding without approval wastes effort if the approach is wrong.

---

## 7. During Work

- [ ] Follow TDD workflow from `docs/tests.md`
- [ ] Keep architecture boundaries (NEVER violate CLAUDE.md warnings)
- [ ] Commit frequently with clear messages
- [ ] Update features.json as you complete sub-tasks

**Use scripts, don't hand-edit JSON:**
```bash
# Mark feature passing (after verification!)
bash scripts/features.sh pass <feature-id>

# Mark feature failing (if regression)
bash scripts/features.sh fail <feature-id>
```

---

## 8. End of Session (MANDATORY)

- [ ] Update `.ai/JOURNAL.md` with session entry (see template below)
- [ ] Update `.ai/features.json` if any features changed status
- [ ] Update `.ai/features.json` `meta.lastUpdated`
- [ ] Commit journal and features.json
- [ ] Push to branch if working on PR
- [ ] Confirm to user: "Session logged. Ready for next session."

**Journal Entry Template:**
```markdown
---
## YYYY-MM-DD HH:MM [AI - {Your Model Name}]
**Session ID:** {unique-id}
**Goal:** {what you were asked to do}
**Completed:** {what actually got done}
**Features:** {feature IDs that changed status}
**Commits:** {SHAs}
**Files Modified:** {key files}
**Tests:** {test results}
**Status:** {completed/in-progress/blocked}
**Next:** {what should happen next session}
**Blockers:** {any issues encountered}
---
```

---

## Document Hierarchy (When Conflicts Arise)

If sources contradict, trust in this order:

1. **`.ai/features.json`** - Feature completion status (source of truth for "is it done?")
2. **`architecture.md`** - System design (source of truth for "how should it work?")
3. **`docs/roadmap.md`** - Phase strategy (source of truth for "what phase are we in?")
4. **`CLAUDE.md` / `WARP.md`** - Tool-specific rules (source of truth for "how to build?")
5. **`.ai/JOURNAL.md`** - Historical record (source of truth for "what happened?")

---

## ⚠️ CRITICAL ARCHITECTURAL BOUNDARIES - DO NOT VIOLATE

### Never Import Platform Frameworks into WristBopCore

**❌ FORBIDDEN:**
```swift
import SwiftUI
import CoreMotion
import WatchKit
import UIKit
```

**✅ ONLY ALLOWED:**
```swift
import Foundation
```

**Why:** WristBopCore is platform-independent shared logic. Platform code belongs in app targets only.

**VIOLATION OF THIS RULE BREAKS THE ENTIRE ARCHITECTURE.**

---

### Never Put Business Logic in SwiftUI Views

**❌ FORBIDDEN:**
- Timers in View structs
- Game state mutations in Views
- CoreMotion code in Views
- Business logic calculations in Views

**✅ REQUIRED:**
- All logic in GameViewModel/GameEngine
- Views only bind to published state
- Views are thin presentation layer

**Views must be presentational only.**

---

### Never Mark Features Complete Without Verification

**❌ FORBIDDEN:**
- Setting `"passes": true` in features.json without running verification
- Marking features complete based on "looks good"
- Skipping manual testing for "Manual:" verification commands

**✅ REQUIRED:**
- Execute verification command from `feature.verification` field
- Confirm tests pass before marking automated features complete
- Perform manual verification for manual tests
- Use `bash scripts/features.sh pass <id>` after verification

**False positives corrupt the feature inventory.**

---

## Quick Reference Commands

```bash
# Verify environment
bash scripts/verify-env.sh

# View features (human-readable)
bash scripts/features.sh summary
bash scripts/features.sh phase "Phase 2"
bash scripts/features.sh next

# Mark feature passing (after verification!)
bash scripts/features.sh pass watch-002

# Mark feature failing
bash scripts/features.sh fail watch-002

# View journal summary
tail -100 .ai/JOURNAL.md

# Run core tests
swift test

# Run watch tests
xcodebuild -scheme "WristBop Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' test

# Run iOS tests
xcodebuild -scheme "WristBop" -destination 'platform=iOS Simulator,name=iPhone 15' test
```

---

## Troubleshooting

**Q: Journal says PR #42 in progress but GitHub shows closed?**
A: Human closed it. Check for `[GITHUB-EVENT]` entry. If missing, assume merged successfully.

**Q: Feature says `passes:true` but verification fails?**
A: Mark as failing, add note to journal, investigate regression.

**Q: Blocked by feature that's not done?**
A: Work on unblocked features first, or ask user if you can unblock.

**Q: Architecture.md conflicts with existing code?**
A: Architecture.md is source of truth. Code may be outdated. Ask user before changing.

**Q: Feature commands fail?**
A: Run `bash scripts/verify-env.sh` and ensure Swift is available.

**Q: Scripts don't have execute permission?**
A: Run: `chmod +x scripts/*.sh`

---

## End of Session Checklist

Before ending your session, verify:

- [ ] Journal entry added to `.ai/JOURNAL.md`
- [ ] Features.json updated if status changed
- [ ] All changes committed with clear messages
- [ ] If working on PR: changes pushed to branch
- [ ] User notified: "Session logged. Ready for next session."

**This checklist is mandatory for session continuity.**

---

**Remember:** This ritual ensures every AI session can pick up exactly where the previous one left off. Never skip steps.
