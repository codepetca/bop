# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

WristBop is a fast-reaction "Bop It"-style game for Apple Watch with an iOS companion app. The project uses a **hybrid Swift Package + Xcode project architecture** where the core game logic lives in a Swift Package (`WristBopCore`) that's shared between platform-specific apps built with Xcode.

### Key Architecture Principles

**Clean Separation of Concerns:**
- `WristBopCore` (SPM package at `Sources/WristBopCore/`) contains pure, platform-independent game logic with no UIKit, SwiftUI, CoreMotion, or watchOS dependencies
- Platform code (watchOS app, iOS app) lives in `WristBop/` and handles all system-level concerns (motion, haptics, UI)
- This separation enables comprehensive unit testing of game logic and allows both apps to share the same core

**Dependency Injection Pattern:**
- Core components like `GameEngine` accept protocols (`CommandRandomizer`, `HighScoreStore`) via initializer injection
- Platform components like `GameViewModel` accept protocols (`GestureDetecting`, `TimerScheduling`) for testability
- Tests use deterministic test doubles (e.g., `SequenceCommandRandomizer` instead of `SystemCommandRandomizer`)

**Testability First:**
- All random behavior is controlled via `CommandRandomizer` protocol
- Motion detection is abstracted behind `GestureDetecting` protocol
- Timer behavior is abstracted behind `TimerScheduling` protocol
- This allows unit tests to be deterministic and fast

## Common Commands

### Core Package (Swift Package Manager)

Build the core package:
```bash
swift build
```

Run core package tests (runs all tests in `Tests/WristBopCoreTests/`):
```bash
swift test
```

Run tests in parallel:
```bash
swift test --parallel
```

Run a specific test by name pattern:
```bash
swift test --filter GameEngineTests
```

### Watch App (Xcode)

Open the Xcode project:
```bash
open WristBop/WristBop.xcodeproj
```

Build and test the watchOS app from command line:
```bash
xcodebuild -scheme "WristBop Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' test
```

Build without testing:
```bash
xcodebuild -scheme "WristBop Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' build
```

### iOS App

Build and test the iOS app:
```bash
xcodebuild -scheme "WristBop" -destination 'platform=iOS Simulator,name=iPhone 15' test
```

### CI/CD

The project uses GitHub Actions (`.github/workflows/ci.yml`) that runs `swift test --parallel` on all branches and PRs using macOS 15 runners.

## Code Organization

### Core Module (`Sources/WristBopCore/`)

The shared game logic module contains:

- **`GameEngine`**: Orchestrates game state, score tracking, difficulty ramping, and high score persistence. The engine uses a protocol (`GameEngineProtocol`) and concrete implementation pattern.
- **`GameState`**: Value type holding current game state (command, score, timing, flags). Includes `didTriggerSpeedUpCue` flag for haptic/sound feedback coordination.
- **`GestureType`**: Enum defining the four gesture types (`.shake`, `.flickUp`, `.twist`, `.spinCrown`). Has `.allCases` for randomization.
- **`GameConstants`**: Centralized tuning values (initial time: 3.0s, minimum: 0.5s, decrement: 0.1s per 3 successes).
- **`CommandRandomizer`**: Protocol for gesture generation with `SystemCommandRandomizer` (production) and `SequenceCommandRandomizer` (testing).
- **`HighScoreStore`**: Protocol for persistence with `UserDefaultsHighScoreStore` (production) and `InMemoryHighScoreStore` (testing).

### Watch App (`WristBop/WristBop Watch App/`)

The watchOS implementation contains:

- **`GameViewModel`**: Main orchestrator (@MainActor) that owns `GameEngine`, manages timers, handles gesture detection callbacks, triggers haptics/sounds, and publishes UI state. Includes countdown logic (3-second timer before game start) and speed-up message display (2-second pause when difficulty increases).
- **`GestureDetector`**: Wraps CoreMotion + WKCrownSequencer. Uses sliding-window sampling with threshold-based detection. Implements one-detection-per-command-window logic to prevent duplicate triggers. Exposes `GestureDetecting` protocol for testing.
- **`HapticsManager`**: Wraps WKInterfaceDevice haptics (`.success`, `.failure`, `.tick`, `.speedUp`).
- **`SoundManager`**: Plays system sounds for game events.
- **`TimerScheduler`**: Protocol abstracting timer behavior with `SystemTimerScheduler` and `MockTimerScheduler` implementations.
- **`ContentView`**: SwiftUI view implementing game screens (main menu, countdown, gameplay with circular progress ring, speed-up overlay, game over).
- **`GestureDetectorConstants`**: Tuning thresholds for motion detection (shake acceleration, flick threshold, twist rotation, crown delta).
- **`FeedbackConstants`**: Constants for haptic/sound identifiers.

### iOS App (`WristBop/WristBop/`)

Currently a minimal scaffold for future features (level selection, multiplayer, leaderboards). Shares `WristBopCore` but doesn't yet have significant implementation.

## Testing Strategy

### Unit Tests (`Tests/WristBopCoreTests/`)

Uses Swift Testing framework (`@Suite`, `@Test`) for the core package. Tests are descriptive and self-documenting:
- "Start game resets state and sets first command"
- "Correct gesture increments score"
- "Wrong gesture is ignored within time window"
- "Difficulty ramps after 3 successes"
- "Speed-up cue triggers when time decreases"
- "Time floor is respected"

All tests use `SequenceCommandRandomizer` for deterministic behavior.

### Watch App Tests (`WristBop/WristBop Watch AppTests/`)

Contains:
- `GameViewModelTests.swift`: Tests ViewModel orchestration logic
- `GestureDetectorTests.swift`: Tests motion detection with injected samples

Use mock implementations (`MockTimerScheduler`, `MockGestureDetector`) to avoid actual timers and motion hardware during testing.

## Important Development Notes

### Platform API Boundaries

**Never import platform frameworks into `WristBopCore`:**
- No `import SwiftUI`, `import CoreMotion`, `import WatchKit`, `import UIKit`
- Core must remain pure Swift with only `import Foundation`
- All platform APIs stay in the app targets

### Motion Detection

`GestureDetector` uses a sliding time window (configurable via `GestureDetectorConstants.sampleWindow`) and only emits one detection per command window. Wrong gestures during the active window are ignored (timeout is the only failure condition). This matches the game design where only timeouts cause failure.

### Game Loop Timing

The game uses a tick-based timer approach:
1. `GameViewModel` starts a timer with the current `timePerCommand` from `GameEngine`
2. Timer ticks every 0.05 seconds to update UI
3. On timeout, `handleTimeout()` ends the game
4. On correct gesture, timer restarts with potentially new duration (if speed increased)

### Speed-Up UX Flow

When difficulty increases (every 3 successes):
1. `GameEngine.handleGestureMatch()` sets `didTriggerSpeedUpCue = true`
2. `GameViewModel` detects this flag and stops timer
3. Shows "SPEED UP!" overlay for 2 seconds with haptic + sound
4. Resumes game with faster timing

### SwiftUI Previews

Keep previews compiling by ensuring preview code doesn't reference watchOS-only APIs. Use conditional compilation or mock data when necessary.

## Tuning Constants

**Game timing** (in `GameConstants`):
- Initial time per command: 3.0 seconds
- Minimum time per command: 0.5 seconds  
- Time decrement per ramp: 0.1 seconds
- Successes required per difficulty ramp: 3

**Gesture detection** (in `GestureDetectorConstants`):
- Motion update interval: 0.02 seconds (50 Hz)
- Sample window: 0.5 seconds
- Shake acceleration threshold: 2.5 g
- Shake peaks required: 3
- Shake peak separation: 0.1 seconds
- Flick up threshold: 2.0 g
- Twist rotation threshold: 3.0 rad/s
- Crown delta threshold: 0.15

All thresholds are consolidated in constant files for easy tuning without diving into implementation logic.

## Commit Message Style

Keep commit messages short, imperative, and scoped. Examples from this project's history:
- `Add 3-second countdown and improve main menu UX`
- `Replace linear progress bar with circular timer ring`
- `Implement GameCore: GestureType, GameState, GameEngine with tests`

Avoid mixing refactors with feature work unless required.
