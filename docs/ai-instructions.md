# WristBop — AI Instructions (TDD, Architecture, Workflow)

Read this before coding. Keeps the watchOS MVP consistent, small, and testable.

## Required Reading Order
1) `architecture.md` (game plan, gestures, difficulty curve)  
2) `TODO.md` (current task list)  
3) `docs/tests.md` (TDD priorities and flow)  
4) Any active issue doc (if/when added)

## Platform & Constraints (watchOS 10)
- SwiftUI only; no storyboards, no UIKit, no Combine unless bridging legacy APIs.
- Logic lives in engines/view models; SwiftUI views stay presentational (no timers or business logic in Views).
- Timers for the command window live in the GameViewModel/engine layer, not in the Views.
- Motion input via CoreMotion + Digital Crown; keep thresholds in constants for tuning.
- Haptics + audio allowed (SoundManager/HapticsManager) but keep APIs thin.
- Debug overlay must be opt-in via compile-time flag.

## Modules & Responsibilities
- **WristBopCore** (`Sources/WristBopCore/`): Shared game logic package
  - `GestureType`, `GameState`, `GameEngine` (+ protocol) — scoring, command generation, difficulty ramp (start 1.4s, -0.1s every 3 successes, floor 0.5s), timeout-only failure, high-score updates
  - Tests in `Tests/WristBopCoreTests/`
- **WristBop Watch App** (`WristBop/WristBop Watch App/`): watchOS app
  - **GestureDetection:** `GestureDetector` (CoreMotion + crown) with delegate; sliding-window detection, one detection per window, ignore wrong gestures, `start/stop/setActiveCommand`
  - **UI:** `RootView`, `MainMenuView`, `GamePlayView`, `GameOverView` — minimal watchOS UI wired to published state; progress/time bar optional
  - **System Integration:** `HapticsManager`, `SoundManager` for tick/success/failure/speed-up cues
  - **Debug Overlay:** compile-time flag to show live motion/crown data and detection status (dev builds only)
- **WristBop** (`WristBop/WristBop/`): iOS companion app
  - Future: level selection, multiplayer, leaderboards, stats

## Core Loop & Rules
- Show command → start timer → accept gestures until timeout → match increments score and speeds up → timeout ends game.
- Only timeouts cause failure; mismatched gestures are ignored within the active window.
- Provide haptic + sound cue when the timer speeds up.

## TDD-First Workflow
- Write or update tests before/with logic changes (see `docs/tests.md`):
  - GameEngine: start/reset, next command, scoring, difficulty ramp every 3 successes, floor respected, timeout-only failure, high-score persistence hooks.
  - GameViewModel timer handling (if extracted): deterministic tick helper, timeout path, match path.
  - Persistence: high score round-trips via `UserDefaults`.
  - GestureDetector: where feasible, inject sample streams/fakes to test thresholds without CoreMotion (unit-level); otherwise document thresholds and rely on debug overlay.
- Keep thresholds and timing constants centralized for easy testing/mocking.

## Small-Change Workflow
1) Check `architecture.md` and `TODO.md` for scope.  
2) Add/adjust tests for engines before implementation.  
3) Implement in the correct module; keep Views thin.  
4) Run tests (add a fast tick helper; avoid real timers in tests).  
5) Update docs if behavior changes (architecture/tests/TODO).

## Feature-Specific Rules
- **New gesture:** add enum case, thresholds/constants, detector branch, tests (fake samples), and UI string; keep detection one-per-window.  
- **Difficulty changes:** update constants + tests; ensure speed-up cue fires once per drop.  
- **Audio/haptics:** add identifiers in one place; avoid duplicating logic in Views.  
- **Debug overlay:** keep behind flag; never ship in release builds.
