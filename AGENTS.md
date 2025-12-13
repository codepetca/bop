# Repository Guidelines

## Project Structure & Module Organization
- Swift package root with shared core at `Sources/WristBopCore/` and tests in `Tests/WristBopCoreTests/` using the `Testing` framework.
- watchOS app lives in `WristBop/WristBop Watch App/`; iOS companion app scaffold in `WristBop/WristBop/`.
- Xcode project and schemes are under `WristBop/WristBop.xcodeproj` (`WristBop`, `WristBop Watch App`, `WristBopCore`).
- High-level design notes: `architecture.md`. Feature inventory and progress: `.ai/features.json` (view with `bash scripts/features.sh summary`).

## Build, Test, and Development Commands
- Core package build: `swift build` (checks `WristBopCore` compiles).
- Core tests: `swift test` (runs `Tests/WristBopCoreTests`).
- watchOS app (Xcode): `open WristBop/WristBop.xcodeproj` to edit; run `xcodebuild -scheme "WristBop Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' test`.
- iOS app: `xcodebuild -scheme "WristBop" -destination 'platform=iOS Simulator,name=iPhone 15' test`.
- SwiftUI previews: keep them compiling by isolating watch-only APIs to the Watch target.

## Coding Style & Naming Conventions
- Follow Swift API Design Guidelines: types `UpperCamelCase`, methods/properties `lowerCamelCase`, constants in `GameConstants`.
- Indent with 4 spaces; favor `struct`/`enum` over classes unless identity or reference semantics are required.
- Prefer dependency injection (see `GameEngine` initializer) and pure functions in `WristBopCore`; keep platform code out of the core module.
- Add doc comments for public APIs and non-obvious logic; keep inline comments brief.
- Keep random behavior testable by seeding/injecting command randomizers (see `SequenceCommandRandomizer`).

## Testing Guidelines
- Unit tests live beside the core in `Tests/WristBopCoreTests`; use `@Suite` and `@Test` with descriptive names (`@Test("Speed-up cue triggers when time decreases")`).
- For new game logic, add deterministic doubles instead of relying on `SystemCommandRandomizer`.
- UI or integration checks belong in UITest targets (`WristBop Watch AppUITests`, `WristBopUITests`); attach screenshots for visual changes when practical.
- Run `swift test` for core changes; run the relevant `xcodebuild ... test` when touching Watch/iOS code or SwiftUI layouts.

## Commit & Pull Request Guidelines
- Commit messages: short, imperative, and scoped (examples from history: `Add 3-second countdown and improve main menu UX`, `Replace linear progress bar with circular timer ring`).
- PRs should include a concise summary, linked issue/Task ID, screenshots for UI-facing changes, and test commands executed.
- Keep changes small and focused; avoid mixing refactors with feature work unless required.

## Security & Configuration Tips
- Motion/haptics access and digital crown use stay in the Watch target; never pull those into `WristBopCore`.
- Avoid storing secrets; high scores persist via `HighScoreStore` only. If adding sync, keep credentials in the Keychain and out of the repo.
