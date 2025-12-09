# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**WristBop** is a fast-reaction "Bop It"-style game for Apple Watch (watchOS 10+). Players respond to on-screen gesture commands (Shake, Flick Up, Twist, Spin Crown) within decreasing time windows. The game speeds up every 3 successful gestures until the player times out.

## Development Commands

### Build and Test
```bash
# Run all tests
swift test

# Run tests in parallel
swift test --parallel

# Build the package
swift build
```


### CI/CD
- CI runs on GitHub Actions (`.github/workflows/ci.yml`)
- Automatically runs `swift test --parallel` on push/PR to any branch
- Uses macOS 14 runner

### Linking Package to Xcode

The `WristBopCore` package is linked to both iOS and watchOS app targets:

1. Open `WristBop/WristBop.xcodeproj` in Xcode
2. Package dependency should already be configured to point to the repository root
3. Both `WristBop` (iOS) and `WristBop Watch App` (watchOS) targets include `WristBopCore`

To use the game engine in app code:
```swift
import WristBopCore

let engine = GameEngine(
    commandRandomizer: SystemCommandRandomizer(),
    highScoreStore: UserDefaultsHighScoreStore()
)
```

## Additional Documentation

Beyond this file, consult these docs for detailed guidance:
- `architecture.md`: Detailed component design, gesture definitions, game loop mechanics
- `TODO.md`: Current task list and implementation status
- `docs/ai-instructions.md`: TDD workflow, module responsibilities, feature-specific rules
- `docs/roadmap.md`: Development phases and MVP goals
- `docs/tests.md`: Testing priorities and patterns

## Architecture

### Core Module Structure

The project follows standard Swift Package conventions with clean separation between shared game logic and platform-specific apps:

**Package Location**: `Sources/WristBopCore/` (standard Swift Package structure)

1. **Game Logic Layer**
   - `GameEngine.swift`: Implements `GameEngineProtocol`, orchestrates game loop, score tracking, difficulty ramping
   - `GameState.swift`: Value type holding current game state (command, score, timing, flags)
   - `GestureType.swift`: Enum defining the 4 gesture types (shake, flickUp, twist, spinCrown)
   - `GameConstants.swift`: Centralized tuning constants for difficulty curve

2. **Supporting Systems**
   - `CommandRandomizer.swift`: Protocol + `SystemCommandRandomizer` for generating random commands (repeats allowed)
   - `HighScoreStore.swift`: Protocol + `UserDefaultsHighScoreStore` for persistence

**Tests Location**: `Tests/WristBopCoreTests/`

**App Targets**: Located in `WristBop/` directory
   - `WristBop Watch App/` - watchOS game app
   - `WristBop/` - iOS companion app (future: level selection, multiplayer, leaderboards)

### Key Design Patterns

- **Protocol-based dependency injection**: `GameEngine` accepts `CommandRandomizer` and `HighScoreStore` protocols, enabling testability
- **Value semantics**: `GameState` is a struct, mutated only by `GameEngine`
- **Failure model**: Only timeouts cause game over; wrong gestures within the time window are ignored
- **Difficulty curve**: Every 3 successes decrease time by 0.1s (floor: 0.5s, start: 1.4s)

### Game State Management

The `GameEngine` tracks:
- Current gesture command
- Score and high score (persisted via `UserDefaults` key `WristBopHighScore`)
- Dynamic time per command (difficulty)
- Game phase flags (`isPlaying`, `isGameOver`)
- Success count for difficulty ramping
- `didTriggerSpeedUpCue` flag for haptic/sound feedback

### Testing Strategy

Tests use protocol-based test doubles:
- `InMemoryHighScoreStore`: In-memory high score for deterministic tests
- `SequenceCommandRandomizer`: Predictable command sequences for testing game flow

All game logic tests are in `Tests/WristBopCoreTests/GameEngineTests.swift`.

## Implementation Status (per TODO.md)

**Completed:**
- ✅ SwiftPM package scaffold
- ✅ Core game logic (`GameEngine`, `GameState`, `GestureType`)
- ✅ Difficulty ramping with speed-up cue flag
- ✅ High score persistence
- ✅ CI workflow

**Remaining:**
- Gesture detection (`GestureDetector` wrapping CoreMotion + Digital Crown)
- System integration (`HapticsManager`, `SoundManager`)
- UI layer (`GameViewModel`, SwiftUI views for watchOS)
- Optional debug overlay for motion data (compile-time flag)
- watchOS app target

## Constants and Tuning

All gameplay tuning is in `GameConstants`:
```swift
initialTimePerCommand = 1.4        // Starting window
minimumTimePerCommand = 0.5        // Speed floor
timeDecrementPerRamp = 0.1         // Time decrease per ramp
successesPerDifficultyRamp = 3     // Successes before speed increase
highScoreKey = "WristBopHighScore" // UserDefaults key
```

## Development Workflow

This project follows a **TDD-first approach**:

1. Write or update tests before/with logic changes
2. Keep thresholds and timing constants centralized for easy testing
3. Use deterministic test helpers (avoid real timers in tests)
4. Keep SwiftUI Views presentational—no business logic or timers in Views
5. Logic lives in engines/view models; Views only bind to published state

**Module Separation**:
- Business logic timers belong in `GameViewModel`/engine layer, never in Views
- Views should be thin SwiftUI presentation layer only
- Use protocol-based dependency injection for testability

## Important Architectural Constraints

1. **Timeout-only failure**: Wrong gestures are silently ignored; only timing out ends the game
2. **Command randomness**: `CommandRandomizer` may consider the previous command but should choose uniformly across all gestures and allow repeats
3. **Speed-up feedback**: `didTriggerSpeedUpCue` flag signals when haptic/sound cue should play (only when time actually decreases, not when at minimum)
4. **Protocol injection**: Never hardcode concrete types in `GameEngine`; use protocol parameters for testability
5. **Debug overlay**: Must be opt-in via compile-time flag, never shipped in release builds

## Next Steps (from architecture.md)

When implementing remaining components:
- **GestureDetector**: Use sliding-window sampling, threshold-based detection, emit at most one detection per command window
- **HapticsManager/SoundManager**: Success/failure/tick/speed-up cues
- **GameViewModel**: Owns engine + detector, manages command timer, triggers feedback, publishes UI state
- **UI Views**: MainMenuView (start + high score), GamePlayView (command + score + timer), GameOverView (final score + play again)
- **Debug overlay**: Compile-time flag for live motion data display
