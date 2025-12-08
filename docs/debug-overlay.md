# Debug overlay

- The watchOS target’s Debug configuration sets `DEBUG_OVERLAY` (see `WristBop.xcodeproj` build settings). Release builds do **not** include the overlay.
- In Debug builds, a ladybug button appears in the top-right of the watch UI. Tap it to toggle the overlay.
- The overlay shows live motion/crown telemetry, current/last detected command, and includes manual gesture trigger buttons (moved out of the main UI).
- Manual buttons are only available inside the overlay; production builds rely solely on sensor detection.
