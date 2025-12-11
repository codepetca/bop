# WristBop

A fast-reaction "Bop It"-style game for Apple Watch.

## Quick Start

### For AI Agents
**Start here:** Read `.ai/START-HERE.md` before doing anything.

### For Human Developers

**First time setup:**
1. Clone repository
2. Install dependencies: `brew install jq` **(required for feature scripts)**
3. Verify environment: `bash scripts/verify-env.sh`
4. Read `architecture.md` for system design

**Working with the project:**
- **View current tasks:** `bash scripts/features-view.sh summary`
- **See what's next:** `bash scripts/features-view.sh next`
- **Run tests:** `swift test`
- **Build watchOS app:** Open `WristBop/WristBop.xcodeproj` in Xcode

**AI-Assisted Development:**
- **Creating issues:** Use protocol in `docs/issue-author.md`
- **Implementing issues:** Use protocol in `docs/issue-worker.md`
- **Reviewing code:** Use protocol in `docs/code-reviewer.md`

**Project Structure:**
- `Sources/WristBopCore/` - Shared game logic (platform-independent)
- `WristBop/WristBop Watch App/` - watchOS implementation
- `WristBop/WristBop/` - iOS companion app
- `.ai/` - AI session continuity layer (journals, feature tracking)
- `docs/` - Development protocols and guides
- `scripts/` - Helper scripts for features and environment

**Key Documentation:**
- `architecture.md` - System design and component overview
- `docs/roadmap.md` - Development phases and strategy
- `CLAUDE.md` - Claude Code specific instructions
- `WARP.md` - Warp terminal AI instructions

## Development Commands

```bash
# Core package
swift build                  # Build WristBopCore
swift test                   # Run core tests
swift test --parallel        # Run tests in parallel

# watchOS app (via xcodebuild)
xcodebuild -scheme "WristBop Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' test

# iOS app
xcodebuild -scheme "WristBop" \
  -destination 'platform=iOS Simulator,name=iPhone 15' test

# Feature management
bash scripts/features-view.sh summary    # View feature status
bash scripts/feature-pass.sh <id>        # Mark feature passing
bash scripts/feature-fail.sh <id>        # Mark feature failing
```

## Contributing

This project uses structured protocols for AI-assisted development:

1. **Creating tasks:** Follow `docs/issue-author.md` to create well-formed issues
2. **Implementing features:** Follow `docs/issue-worker.md` for the workflow
3. **Code review:** Use `docs/code-reviewer.md` for review standards

All work should update the project journal (`.ai/JOURNAL.md`) to maintain continuity.

## Architecture

See `architecture.md` for complete design documentation.

**Key principles:**
- Clean separation: `WristBopCore` is platform-independent
- Dependency injection: Protocols for testability
- TDD workflow: Tests before/with implementation
- Timeout-only failure: Wrong gestures are ignored

## Game Rules

- **4 gestures:** Shake, Flick Up, Twist, Spin Crown
- **Starting time:** 3.0 seconds per command
- **Speed-up:** Every 3 successes reduces time by 0.1s
- **Minimum time:** 0.5 seconds
- **Failure condition:** Timeout only (wrong gestures ignored)
- **High score:** Persisted via UserDefaults, shared between watchOS and iOS

## License

[Your license here]
