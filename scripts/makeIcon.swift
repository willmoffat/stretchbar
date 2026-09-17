#!/usr/bin/env swift
import AppKit

let size = 1024
let rep = NSBitmapImageRep(
  bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
  bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
  colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = NSSize(width: size, height: size)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let bounds = NSRect(x: 0, y: 0, width: size, height: size)
let bg = NSBezierPath(roundedRect: bounds, xRadius: 180, yRadius: 180)
NSColor.black.setFill()
bg.fill()

let bar = NSRect(x: 100, y: 744, width: 824, height: 80)
let barPath = NSBezierPath(roundedRect: bar, xRadius: 40, yRadius: 40)
NSColor(red: 1, green: 0.23, blue: 0.19, alpha: 1).setFill()
barPath.fill()

NSGraphicsContext.restoreGraphicsState()

let png = rep.representation(using: .png, properties: [:])!
let scriptDir = URL(fileURLWithPath: #file).deletingLastPathComponent()
let out = scriptDir.deletingLastPathComponent().appendingPathComponent(
  "StretchBar/Assets.xcassets/AppIcon.appiconset/icon.png")
try! png.write(to: out)
print("Written to \(out.path)")
