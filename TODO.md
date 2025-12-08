# WristBop TODO

## Project Structure
- [x] Scaffold SwiftPM core package (`Sources/WristBopCore/`) with CI
- [x] Implement GameCore: `GestureType`, `GameState`, `GameEngine` (protocol + concrete) with start/reset, random next command, match handling, timeout-only failure, score/high-score updates, and difficulty ramp with haptic+sound cue
- [x] Add persistence for high score via `UserDefaults` key `WristBopHighScore`
- [x] Write comprehensive unit tests for `GameEngine` (11 tests passing)
- [x] Add CI workflow to run `swift test`
- [x] Create Xcode project with watchOS app + iOS companion app
- [x] Link `WristBopCore` package to both Xcode app targets

## watchOS MVP
- [ ] Define shared constants for gesture thresholds, timer tuning (start 1.4s, -0.1s every 3 successes, floor 0.5s), and haptic/sound identifiers
- [ ] Build `GestureDetector` wrapping CoreMotion + crown events: start/stop, `setActiveCommand`, sliding-window sampling, thresholds for shake/flick up/twist/spin, emit at most one detection per command window, ignore mismatches
- [ ] Create `HapticsManager` for success/failure/tick/speed-up cues and `SoundManager` for the same set of events
- [ ] Implement `GameViewModel` owning engine + detector: manage command timer, relay detections, trigger haptics/sounds, publish UI state, handle timeout-only failure logic
- [ ] Build SwiftUI views: `RootView`, `MainMenuView` (start + high score), `GamePlayView` (command, score, progress/time bar), `GameOverView` (score/high score, play again). Keep styling minimal/standard
- [ ] Add optional debug overlay (compile-time flag) to display live accelerometer/gyro/crown data and detection status

## iOS Companion App
- [x] Basic app structure and WristBopCore integration
- [x] Navigation scaffold with placeholder views (HomeView, LevelSelectionView, SettingsView, StatsView, AboutView)
- [x] Centralized Theme configuration for easy customization
- [x] High score display shared with watchOS app
- [x] iOS unit tests verifying WristBopCore linking
- [ ] Level selection UI implementation
- [ ] Difficulty mode settings implementation
- [ ] Stats and leaderboards with Game Center integration
- [ ] Multiplayer features
- [ ] Full settings and customization features
