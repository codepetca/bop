# WristBop Roadmap (Source of Truth)

> **Note:** This file defines phases and strategic milestones for humans.
> **For AI agents:** Detailed feature tracking is in `.ai/features.json`
> (This file and features.json should stay roughly aligned, but features.json is the status authority)

Status legend: **Next** = current focus, **Planned** = queued, **Future** = post-MVP.

## MVP Goal
Ship a watchOS 10 WristBop with four gestures (shake, flick up, twist, spin crown), endless loop, timeout-only failure, start at ~3s per command with -0.1s every 3 successes to a 0.5s floor, haptic+sound cues, high score persistence, debug overlay behind a compile-time flag, and tests for core logic.

## Phase 0 — Setup & Guardrails (Next)
- Create watchOS 10 SwiftUI app target, shared constants, and test target.
- Land AI instructions/tests docs (done) and keep docs aligned with `.ai/features.json`.
- Add swift test runner workflow (local) and deterministic clock helpers.

## Phase 1 — GameCore via TDD (Next)
- Implement `GestureType`, `GameState`, constants.
- TDD `GameEngine`: start/reset, next command, scoring, difficulty ramp every 3 successes, timeout-only failure, high-score updates.
- Persistence stub for high score (`UserDefaults`).
- Unit tests covering ramp/floor and high-score path.

## Phase 2 — Gesture Detection & Instrumentation (Planned)
- Implement `GestureDetector` (CoreMotion + crown) with delegate and one-detection-per-window rule; thresholds in constants.
- Add injectable sample/fake path to allow unit-style tests where possible.
- Add debug overlay (compile-time flag) for motion/crown data and detection status.

## Phase 3 — UI & Loop Wiring (Planned)
- Build `GameViewModel` orchestrating timers, detector activation, and engine callbacks; tests with deterministic ticks.
- SwiftUI views: `RootView`, `MainMenuView`, `GamePlayView`, `GameOverView`; minimal styling; progress/time bar optional.
- Wire haptics/sound cues for tick, success, failure, speed-up.

## Phase 4 — Polish & QA (Planned)
- Tune thresholds and difficulty constants from on-device testing.
- Add audio assets/identifiers; ensure haptics patterns feel distinct.
- Ensure release build disables debug overlay; confirm high-score persistence durability.
- Light UI smoke tests (if feasible) and manual pass on device/simulator.

## Phase 5 — Future (Future)
- Additional gestures (tap/raise/drop) and themes.
- iPhone companion app and leaderboards.
- Daily challenges/cosmetics once core loop is solid.
