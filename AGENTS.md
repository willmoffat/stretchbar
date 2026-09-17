# StretchBar

Minimal macOS app that displays a growing thin red bar along the top edge of the screen when it's time to stretch.

## Behavior

- Bar grows horizontally from top-left to top-right over 60 seconds
- No window decoration (no title bar, no close/minimize/maximize buttons) and no dock icon and no menu bar.
- Displays above all other windows (always on top), visible on all desktops
- Clicking the bar (or sending a `dev.moffat.dismissStretch` distributed notification) hides it for X minutes, then it reappears and starts growing again
- On screen unlock, if the bar is visible (growing or full), growth restarts from zero — a full 1-point bar is easy to miss when it's not moving
- On display changes (lid open/close, cable plug/unplug), a full-width bar is repositioned to the active screen
- Launches at login (Release builds only, via SMAppService)

## Why

macOS notifications are unreliable for persistent reminders — they can be silenced, grouped, or missed entirely. This app provides a guaranteed-visible, non-intrusive visual cue.

## Configuration

Edit `~/.config/stretchbar.json` (changes picked up on next dismiss/reappear cycle):

```json
{"delayShowSec": 2400, "growDurationSec": 40, "barHeightPt": 3}
```

- `delayShowSec` — seconds hidden after dismiss (default: 300)
- `growDurationSec` — seconds to grow from 0 to full height (default: 60)
- `barHeightPt` — bar height in points (default: 1)

## Implementation

- Pure AppKit (no SwiftUI) — single file `StretchBarApp.swift`
- Borderless `NSWindow` at `.floating` level with `.accessory` activation policy
- Timer-driven growth animation at ~30fps
- Window x-origin uses `screen.minX` (not `0`) to handle multi-monitor setups where the external display's origin is non-zero in global coordinates
- `NSScreen.main` tracks the screen with current keyboard focus (key window), so the bar follows the active display
- Debug builds show magenta bar; Release builds show red
- App Sandbox disabled (required for floating window behavior)

## Scripts

- `./scripts/build-install-run.sh` — kill any running instance, clean Release build, install to /Applications, then prompt to launch
- `./scripts/build-install-dismiss.sh` — compile the dismiss helper (`raycast/dismiss.swift`) to `~/.local/bin/stretchbar-dismiss`
- `./scripts/show-errors.sh [duration]` — show the app's error/fault logs (default last 10m), filtering known-harmless system noise
- `./scripts/makeIcon.swift` — generates the app icon PNG
- `./scripts/format-all.sh` — run swift-format on the project

## Dismiss helper

`raycast/dismiss.swift` is a companion tool that posts the `dev.moffat.dismissStretch` distributed notification, triggering the same dismiss path as clicking the bar. It's compiled to a native binary at `~/.local/bin/stretchbar-dismiss` (via `scripts/build-install-dismiss.sh`) so a launcher like Raycast can bind it to a hotkey and trigger it near-instantly. Recompile after editing the source.

## Design decisions and constraints

- App Sandbox is disabled. This is required for the floating window and direct file access to `~/.config/`. The app has no network code or user input beyond a click, so the security impact is negligible. Trade-off: cannot distribute via the Mac App Store.
- `UserDefaults` / `defaults write` does not work reliably with this app due to `cfprefsd` caching issues on modern macOS. Config is read from a JSON file instead.
- Do not `strip` the binary after signing — it invalidates the code signature and Gatekeeper will block the app.
- The build script uses `clean build` to ensure a fresh binary with valid signature.
- Window level must stay at `.floating`. Using `CGShieldingWindowLevel()` to draw above the menu bar causes the bar to disappear as it passes through the camera notch.
