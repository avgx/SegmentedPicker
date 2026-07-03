# SegmentedPicker

Thin SwiftUI wrapper around the system `Picker(.segmented)` with built-in `.fixedSize()` sizing, plus an async variant for selections that require network or other slow operations.

Designed for iOS 15+, tvOS 18+, macOS 13+, and visionOS 1+.

## Components

| Component | Purpose |
|-----------|---------|
| `SegmentedPicker` | Synchronous segmented control — immediate `selection` updates |
| `AsyncSegmentedPicker` | Async `onChange` with loading shimmer, rollback on failure |

Both use the native segmented control under the hood. No custom drawing, no extra backgrounds — the toolbar or list row provides its own chrome (for example Liquid Glass capsule in `bottomBar` on iOS 26).

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/avgx/SegmentedPicker", from: "1.0.0"),
]
```

```swift
import SegmentedPicker
```

## SegmentedPicker

Drop-in replacement for:

```swift
Picker("", selection: $mode) { ... }
    .pickerStyle(.segmented)
    .fixedSize()
```

### Usage

```swift
enum Mode: String, CaseIterable, Hashable {
    case live, playback

    var title: String { rawValue.capitalized }
    var systemImage: String {
        switch self {
        case .live: "video"
        case .playback: "memories"
        }
    }
}

@State private var mode = Mode.live

SegmentedPicker(Mode.allCases, selection: $mode) { mode in
    Label(mode.title, systemImage: mode.systemImage)
}
```

### Toolbar bottom bar (iOS)

```swift
ToolbarItem(placement: .bottomBar) {
    SegmentedPicker(Mode.allCases, selection: $mode) { mode in
        Label(mode.title, systemImage: mode.systemImage)
    }
}
```

The system toolbar draws the outer capsule. Do not wrap the picker in additional glass or material backgrounds.

### In a List row

```swift
List {
    HStack {
        Text("Mode")
        Spacer()
        SegmentedPicker(Mode.allCases, selection: $mode) { mode in
            Text(mode.title)
        }
    }
}
```

The picker keeps its intrinsic width and does not stretch across the row.

### Segment content

Any of these work as segment labels:

```swift
// icon + text
Label("Live", systemImage: "dot.radiowaves.left.and.right")

// text only
Text("ARM")

// icon only
Image(systemName: "video")
```

Segments size to their content. Widths may differ between segments.

## AsyncSegmentedPicker

For selections that must complete an async operation before committing — for example ARM/DISARM with a server call that may fail.

```swift
enum ArmDisarm: String, CaseIterable, Hashable {
    case arm, disarm
    var title: String { rawValue.uppercased() }
}

@State private var state = ArmDisarm.arm

AsyncSegmentedPicker(ArmDisarm.allCases, selection: $state) { newValue in
    try await camera.setArmState(newValue)
} content: { item in
    Text(item.title)
}
```

Optional error handler:

```swift
AsyncSegmentedPicker(ArmDisarm.allCases, selection: $state,
    onChange: { try await camera.setArmState($0) },
    onError: { error in /* show alert */ }
) { item in
    Text(item.title)
}
```

### Behavior

1. User taps a segment — the picker UI updates immediately (native `Picker` behavior).
2. `onChange` runs asynchronously — a **capsule-shaped shimmer** overlays the entire control.
3. Interaction is disabled until the operation finishes.
4. **Success** — `selection` binding is updated to the new value.
5. **Failure** — the picker rolls back to the previous value; `onError` is called if provided.
6. While loading, further taps are ignored.

## Sizing

`.fixedSize()` is applied internally. You do not need to add it yourself.

The control reports its natural width (sum of segment widths) and does not expand to fill available space unless you add `.frame(maxWidth: .infinity)` externally.

## Previews

Preview sources live in `Sources/SegmentedPicker/Preview/` and compile only in `#if DEBUG`.

Open the package in Xcode and use the preview canvas. Each scenario has separate **Light** and **Dark** previews (same style as [TimeUI](https://github.com/avgx/TimeUI)):

| Preview | Component | Placement |
|---------|-----------|-----------|
| Live Playback Plain | `SegmentedPicker` | standalone |
| Live Playback List Row | `SegmentedPicker` | `List` row |
| Live Playback Toolbar Top | `SegmentedPicker` | navigation bar |
| Live Playback Toolbar Bottom | `SegmentedPicker` | bottom bar |
| ARM DISARM … | `AsyncSegmentedPicker` | plain / list / toolbar |

## Platform notes

### iOS

- **bottomBar** — preferred placement for LIVE/PLAYBACK-style controls; toolbar provides Liquid Glass capsule on iOS 26.
- **principal** (top toolbar) — works for previews; in production segmented controls in the top bar can be cramped or unstable. Prefer `bottomBar` when possible.

### macOS / tvOS

- `bottomBar` is not available; previews use `safeAreaInset(edge: .bottom)` as a fallback.
- Top toolbar uses `.automatic` placement.

## What this package does not do

- Custom segmented control rendering (drag-to-switch, custom indicator, haptics)
- Per-segment disabled state
- Equal-width segments
- Extra glass/material wrapper around the control

For those cases, build a custom control or use `ControlGroup` / individual toolbar buttons.

## Requirements

- Swift 6.2+
- iOS 15+
- macOS 13+
- tvOS 18+
- visionOS 1+

## License

See repository license file.
