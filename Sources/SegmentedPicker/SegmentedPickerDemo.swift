import SwiftUI

// MARK: - Demo types

private enum LiveOrPlayback: String, CaseIterable, Hashable {
    case live
    case playback

    var title: String {
        switch self {
        case .live: "Live"
        case .playback: "Playback"
        }
    }

    var systemImage: String {
        switch self {
        case .live: "video"
        case .playback: "memories"
        }
    }
}

private enum ArmDisarm: String, CaseIterable, Hashable {
    case arm
    case disarm

    var title: String { rawValue.uppercased() }
}

private enum DemoError: Error {
    case failed
}

private enum IconTab: String, CaseIterable, Hashable {
    case photos
    case albums
    case search

    var systemImage: String {
        switch self {
        case .photos: "photo"
        case .albums: "rectangle.stack"
        case .search: "magnifyingglass"
        }
    }
}

// MARK: - Preview screens

#if os(iOS)
private struct LivePlaybackBottomBarDemo: View {
    @State private var mode = LiveOrPlayback.live

    var body: some View {
        if #available(iOS 18.0, *) {
            NavigationStack {
                Text("\(Image(systemName: mode.systemImage)) \(mode.title)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            SegmentedPicker(LiveOrPlayback.allCases, selection: $mode) { mode in
                                    Label(mode.title, systemImage: mode.systemImage)
                                
                            }
                        }
                        
                    }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
#endif

private struct ArmDisarmInplaceDemo: View {
    @State private var state = ArmDisarm.arm

    var body: some View {
        List {
            HStack {
                Text("Mode")
                Spacer()
                SegmentedPicker(ArmDisarm.allCases, selection: $state) { item in
                    Text(item.title)
                }
            }
        }
    }
}

private struct IconOnlyDemo: View {
    @State private var tab = IconTab.photos

    var body: some View {
        SegmentedPicker(IconTab.allCases, selection: $tab) { tab in
            Image(systemName: tab.systemImage)
        }
        .padding()
    }
}

private struct TextOnlyDemo: View {
    @State private var state = ArmDisarm.arm

    var body: some View {
        SegmentedPicker(ArmDisarm.allCases, selection: $state) { item in
            Text(item.title)
        }
        .padding()
    }
}

private struct MixedWidthsDemo: View {
    @State private var choice = "Short"
    private let options = ["Short", "Much longer"]

    var body: some View {
        SegmentedPicker(options, selection: $choice) { option in
            Text(option)
        }
        .padding()
    }
}

private struct FixedSizeComparisonDemo: View {
    @State private var native = false
    @State private var custom = false

    var body: some View {
        VStack(spacing: 24) {
            Picker("Request Type", selection: $native) {
                Text("Original")
                    .padding(.horizontal, 16)
                    .tag(false)
                Text("Current")
                    .padding(.horizontal, 16)
                    .tag(true)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()

            SegmentedPicker([false, true], selection: $custom) { value in
                Text(value ? "Current" : "Original")
            }
        }
        .padding()
    }
}

// MARK: - Previews

#if os(iOS)
#Preview("livePlayback_bottomBar") {
    LivePlaybackBottomBarDemo()
}
#endif

#Preview("armDisarm_inplace") {
    ArmDisarmInplaceDemo()
}

#Preview("iconOnly") {
    IconOnlyDemo()
}

#Preview("textOnly") {
    TextOnlyDemo()
}

#Preview("mixedWidths") {
    MixedWidthsDemo()
}

#Preview("fixedSizeComparison") {
    FixedSizeComparisonDemo()
}
