# WristBop — Tests & TDD Guide

Focus tests on logic and timing; keep SwiftUI thin. Favor TDD for engines/view models.

## Priorities (highest → lowest)
- **GameEngine:** start/reset state, next command selection, timeout-only failure, scoring and high-score updates, difficulty ramp (start 1.4s, -0.1s every 3 successes, floor 0.5s) with speed-up cue trigger.
- **GameViewModel (timer orchestration):** deterministic tick helper; match path ends window early; timeout path ends game; timer invalidation on end.
- **Persistence:** high score round-trips via `UserDefaults` key `WristBopHighScore`.
- **GestureDetector (where feasible):** threshold logic via injected sample streams/fakes; enforce one detection per window; ignore mismatched gestures.
- **UI smoke (optional):** minimal snapshot/smoke that command/score renders; do not add timers in views.

## Suggested TDD Flow
1) **Models/constants:** define `GestureType`, `GameState`, timing/threshold constants; no logic yet. Add tiny tests if needed for defaults.
2) **GameEngine (tests first):**
   - `startGame` resets state, sets time to 1.4s, picks a command.
   - `handleGestureMatch` increments score, every 3 successes reduces timer by 0.1s until 0.5s floor, sets next command, raises speed-up cue when the timer drops.
   - `handleTimeout` ends game and sets game-over flags; no failure on wrong gesture.
   - High score updated when score exceeds saved value (can mock persistence).
3) **GameViewModel timer (tests alongside code):**
   - Deterministic tick API (no real Timer in tests) counts down; timeout triggers engine; match cancels timer early.
   - Ensures `GestureDetector.setActiveCommand` is called when commands change.
4) **Persistence:** test `UserDefaults` round-trips for high score; isolate with a test suite-specific suite name.
5) **GestureDetector:** if detection is abstracted to pure helpers, test thresholds on synthetic motion windows (shake peaks, flick up spike, twist gyro magnitude, crown delta); otherwise rely on manual + debug overlay but keep logic injectable for future tests.

## Test Hygiene
- Avoid real timers/CoreMotion in tests; inject clocks/samples/fakes.
- Keep tests fast and deterministic; use small sample arrays for detector checks.
- Update tests whenever tuning constants or difficulty rules change.
- If behavior changes, update `architecture.md` and this doc to stay in sync.
