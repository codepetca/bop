# Debug overlay

## How to Enable/Disable

**To enable the debug overlay:**
1. Open `WristBop/WristBop.xcodeproj` in Xcode
2. Select the project → **"WristBop Watch App"** target
3. Go to **Build Settings** tab
4. Search for **"Active Compilation Conditions"**
5. Under **Debug** configuration, add `DEBUG_OVERLAY` to the list
6. Rebuild the app

**To disable:**
- Remove `DEBUG_OVERLAY` from the Active Compilation Conditions

**Current status:** `DEBUG_OVERLAY` is **ENABLED** in the WristBop Watch App Debug configuration.

## Usage

- The watchOS target's Debug configuration can set `DEBUG_OVERLAY` (see `WristBop.xcodeproj` build settings). Release builds do **not** include the overlay.
- In Debug builds with the flag enabled, a ladybug button appears in the top-right of the watch UI. Tap it to toggle the overlay.
- The overlay shows live motion/crown telemetry, current/last detected command, and includes manual gesture trigger buttons (moved out of the main UI).
- Manual buttons are only available inside the overlay; production builds rely solely on sensor detection.

## Layout (compact, no scrolling)

- Detector state, active command, and last detection render as small chips with SF Symbols so they fit on-screen together.
- Accelerometer, gyro, and crown delta live on a single condensed row with monospaced values to minimize height.
- Manual triggers stay in a 2x2 grid (text-only) with at least 44pt tap targets and remain visible alongside telemetry on 41mm and 45mm watches (no scrolling).
- Placeholder values render when telemetry is unavailable so the layout height stays stable while the overlay is open.
