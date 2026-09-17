import AppKit
import ServiceManagement

#if DEBUG
  let isDebug = true
#else
  let isDebug = false
#endif

// Configure via: ~/.config/stretchbar.json
// Example: {"delayShowSec": 300, "growDurationSec": 60, "barHeightPt": 2}

func loadConfig() -> [String: Double] {
  let path = NSHomeDirectory() + "/.config/stretchbar.json"
  guard let data = FileManager.default.contents(atPath: path),
    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
  else { return [:] }
  return json.compactMapValues { ($0 as? NSNumber)?.doubleValue }
}

func pref(_ key: String, fallback: Double) -> Double {
  let v = loadConfig()[key] ?? 0
  return v > 0 ? v : fallback
}

var growTimer: Timer?
var showTimer: Timer?

func startGrowing(_ window: NSWindow) {
  let growDuration = pref("growDurationSec", fallback: 60)
  let height = pref("barHeightPt", fallback: 1)
  let startTime = Date()
  window.setFrame(.zero, display: false)
  window.orderFront(nil)

  growTimer?.invalidate()
  growTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30, repeats: true) {
    timer in
    guard let screen = NSScreen.main?.frame else { return }
    let elapsed = Date().timeIntervalSince(startTime)
    let progress = min(elapsed / growDuration, 1.0)
    let width = screen.width * progress
    let y = screen.maxY - height  // Active monitor can change during grow.
    window.setFrame(
      NSRect(x: screen.minX, y: y, width: width, height: height),
      display: true
    )
    if progress >= 1.0 { timer.invalidate() }
  }
}

func dismiss(_ window: NSWindow) {
  growTimer?.invalidate()
  showTimer?.invalidate()
  window.orderOut(nil)
  let delaySec = pref("delayShowSec", fallback: 300)
  showTimer = Timer.scheduledTimer(withTimeInterval: delaySec, repeats: false) {
    _ in
    startGrowing(window)
  }
}

class ClickView: NSView {
  override func mouseDown(with event: NSEvent) {
    guard let window = window else { return }
    dismiss(window)
  }
}

@main
enum App {
  static func main() {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)  // No dock icon, no menu bar
    app.run()
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ notification: Notification) {
    if !isDebug { try? SMAppService.mainApp.register() }  // Launch at login
    let window = NSWindow(
      contentRect: .zero,  // Size handled by startGrowing().
      styleMask: .borderless,  // No title bar, no buttons
      backing: .buffered,  // Draw to off-screen buffer; required and only option on modern macOS
      defer: false  // Create window server resources immediately
    )
    window.level = .floating  // Always on top of other windows
    window.collectionBehavior = [.canJoinAllSpaces, .stationary]  // Visible on all desktops, stays in place
    window.backgroundColor = isDebug ? .magenta : .red
    window.contentView = ClickView()
    window.orderFrontRegardless()  // Show even though app is not active
    startGrowing(window)

    DistributedNotificationCenter.default().addObserver(
      forName: NSNotification.Name("dev.moffat.dismissStretch"),
      object: nil,
      queue: .main
    ) { _ in dismiss(window) }

    // When the user returns (unlock/wake) and the bar is visible, restart growth.
    DistributedNotificationCenter.default().addObserver(
      forName: NSNotification.Name("com.apple.screenIsUnlocked"),
      object: nil,
      queue: .main
    ) { _ in
      if window.isVisible { startGrowing(window) }
    }

    // Reposition full-width bar when displays change (lid open/close, cable plug/unplug).
    NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { _ in
      if window.isVisible, growTimer == nil || !growTimer!.isValid {
        guard let screen = NSScreen.main?.frame else { return }
        let height = pref("barHeightPt", fallback: 1)
        window.setFrame(
          NSRect(x: screen.minX, y: screen.maxY - height, width: screen.width, height: height),
          display: true
        )
      }
    }
  }
}
