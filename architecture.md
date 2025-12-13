# WristBop Architecture & Implementation Plan

> **For AI Agents:** This is the architectural source of truth.
> Read relevant sections as needed (referenced by `.ai/START-HERE.md` and `.ai/features.json`).
> For session workflow, start with `.ai/START-HERE.md`.

---

## 1. High-Level Concept

**Working title:** `WristBop`
**Platforms:** Apple Watch (watchOS 10) + iOS Companion App (iOS 16+)
**Languages:** Swift, SwiftUI, CoreMotion

A fast-reaction "Bop It"-style game for Apple Watch. The watch displays commands like **Shake it!**, **Twist it!**, **Flick it!**, **Spin it!** and the player performs the gesture within a short window. The game speeds up until failure.

MVP Goals (watchOS):
- Single-player endless mode
- 4 gestures: **Shake**, **Flick Up**, **Twist**, **Spin Crown**
- Score + high score
- Haptics + simple feedback
- Minimal UI

iOS Companion App (Future):
- Level selection and difficulty modes
- Multiplayer features
- Leaderboards and stats
- Settings and customization  

---

## 2. Gestures Included in MVP

### Gesture Enum

```swift
enum GestureType: String, CaseIterable {
    case shake
    case flickUp
    case twist
    case spinCrown
}
```

### Definitions

- **Shake**: rapid alternating accelerometer peaks  
- **Flick Up**: short upward acceleration spike  
- **Twist**: wrist rotation using gyroscope  
- **Spin Crown**: crown rotation delta > threshold  

---

## 3. Game Design Overview

### Core Loop
1. Display command  
2. Start timer (initial ~3 seconds; see `GameConstants.initialTimePerCommand`)  
3. Player performs gesture  
4. Match → increase score & speed → next command  
5. Failure → game over screen  

Notes:
- Only timeouts cause failure; mismatched gestures are ignored within the window.

### Difficulty Curve
- Start at **~3 seconds** per command (tuning: `GameConstants.initialTimePerCommand`)  
- After every **3 successes**, reduce time per command by **0.1 seconds**  
- Minimum time **0.5 seconds**  
- Provide a noticeable haptic + sound cue whenever speed increases  

---

## 4. Architecture Overview

### Modules

1. **WristBopCore** (Swift Package at `Sources/WristBopCore/`)
   - Shared game logic used by both watchOS and iOS apps
   - `GameState`, `GameEngine`, `GestureType`, `GameConstants`
   - `CommandRandomizer`, `HighScoreStore`
   - Platform-independent, fully tested

2. **WristBop Watch App** (`WristBop/WristBop Watch App/`)
   - watchOS game implementation
   - **GestureDetection**: `GestureDetector` wrapping CoreMotion + Digital Crown
   - **UI**: `RootView`, `MainMenuView`, `GamePlayView`, `GameOverView`
   - **System Integration**: `HapticsManager`, `SoundManager`
   - Debug overlay (compile-time flag) for motion data

3. **WristBop (iOS)** (`WristBop/WristBop/`)
   - iOS companion app scaffold (completed)
   - **Navigation Structure**: NavigationStack-based with HomeView as root
   - **Views**:
     - `HomeView`: Main screen with high score display and feature navigation
     - `LevelSelectionView`: Placeholder for future level/difficulty selection
     - `SettingsView`: Placeholder for app customization
     - `StatsView`: Placeholder for stats tracking and leaderboards
     - `AboutView`: App information and game instructions
   - **Theme System**: `Theme.swift` provides centralized color scheme ("Electric Pulse" theme with electric purple #6366F1 and cyan #22D3EE accents)
   - **WristBopCore Integration**: Linked and verified via unit tests
   - **High Score Sharing**: Uses same `UserDefaults` key as watchOS app for seamless sync
   - Future features: full implementation of level selection, multiplayer, Game Center leaderboards
   - Build command: `xcodebuild -scheme "WristBop" -destination 'platform=iOS Simulator,name=iPhone 15' test`  

---

## 5. Detailed Components

### 5.1 GameState

```swift
struct GameState {
    var currentCommand: GestureType?
    var score: Int
    var highScore: Int
    var timePerCommand: TimeInterval
    var isGameOver: Bool
    var isPlaying: Bool
}
```

### 5.2 GameEngine Protocol

```swift
protocol GameEngineProtocol {
    var state: GameState { get }

    func startGame()
    func endGame()
    func handleGestureMatch(_ gesture: GestureType)
    func handleTimeout()
    func nextCommand()
}
```

### Responsibilities
- Start/reset game  
- Generate next command  
- Handle success/fail  
- Update score & difficulty  

---

## 6. Gesture Detection

### GestureDetector

```swift
protocol GestureDetectorDelegate: AnyObject {
    func gestureDetector(_ detector: GestureDetector, didDetect gesture: GestureType)
}

final class GestureDetector: ObservableObject {
    weak var delegate: GestureDetectorDelegate?

    func start()
    func stop()

    func setActiveCommand(_ command: GestureType?)
}
```

### Detection Logic
- **Shake:** multiple acceleration peaks  
- **Flick Up:** strong upward spike  
- **Twist:** rotation rate magnitude  
- **Spin Crown:** rapid crown delta  

### Notes for AI Implementor
- Use threshold-based detection  
- Use sliding window for motion samples  
- Emit only one detection per command window  
- Wrong gestures within the window should not trigger failure  

---

## 7. ViewModel / UI Binding

### GameViewModel

- Owns `GameEngine` + `GestureDetector`  
- Controls timers  
- Updates UI via `@Published` properties  
- Plays haptics on match/failure  

---

## 8. Views

- **MainMenuView**: Start button, high score  
- **GamePlayView**: Current command, score, optional progress bar  
- **GameOverView**: Final score, high score, Play Again button  

---

## 9. Haptics

Use:

- `.success` → match  
- `.failure` → timeout  
- subtle tick → new command  
- Haptic + sound cue when difficulty increases  

---

## 10. Persistence

Store high score in `UserDefaults`  
Key: `"WristBopHighScore"`

---

## 11. Testing Instructions (For AI)

- Write unit tests for `GameEngine`:
  - Start resets state  
  - Correct gesture increments score  
  - Timeout ends game  
- Optional: enable debug overlay showing live accelerometer/gyro data (behind compile-time flag)  

---

## 12. Instructions to AI Implementing This

> **AI IMPLEMENTATION NOTES**  
>  
> - Use **SwiftUI** and **watchOS 10** APIs  
> - Implement the modules exactly as defined  
> - Focus on **gesture detection accuracy** and **game responsiveness**  
> - All thresholds must be placed in constants for easy tuning  
> - File structure must be clean, modular, and extendable  
> - Produce commented, production-quality Swift code  
> - Include unit tests for GameEngine  
> - Keep UI minimal but polished  
> - Include audio (SoundManager) in MVP  
> - Debug overlay should be opt-in via compile-time flag  

---

## 13. Future Extensions

### iOS Companion App Features
- Level selection and difficulty modes
- Multiplayer modes
- Leaderboards and Game Center integration
- Stats and progress tracking
- Settings and customization

### Additional Game Features (Post-MVP)
- Additional gestures (Tap, Raise/Lift, Drop)
- Themes (sci-fi, magic, fitness)
- Daily challenges
- Cosmetic unlocks
- Power-ups and special modes  

---

# End of WristBop MVP Architecture Document
