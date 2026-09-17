import Foundation

// Companion tool for StretchBar. Posts the distributed notification that the
// app listens for to hide the bar. Compiled to a native binary (see
// scripts/build-install-dismiss.sh) so Raycast can trigger it near-instantly
// instead of interpreting Swift on every invocation.

DistributedNotificationCenter.default().postNotificationName(
  NSNotification.Name("dev.moffat.dismissStretch"),
  object: nil,
  deliverImmediately: true
)
