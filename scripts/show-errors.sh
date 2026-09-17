#!/bin/bash
LAST="${1:-10m}"
log show --predicate 'process == "StretchBar" AND (messageType == error OR messageType == fault)' --last "$LAST" \
  | grep -v "\[com.apple.os_debug_log\].*assertion failed:.*libxpc.dylib" `# system XPC assertion triggered because the app has no dock/menu presence; Apple's frameworks emit this for .accessory apps — harmless and unfixable` \
  | grep -v "CALocalDisplayUpdateBlock returned NO" `# compositor skipped a frame — cosmetic, unavoidable with rapid resizes`
