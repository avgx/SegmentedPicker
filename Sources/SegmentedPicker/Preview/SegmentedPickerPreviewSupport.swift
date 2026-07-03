#if DEBUG
import SwiftUI

// MARK: - Preview types

enum LiveOrPlayback: String, CaseIterable, Hashable {
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

enum ArmDisarm: String, CaseIterable, Hashable {
    case arm
    case disarm

    var title: String { rawValue.uppercased() }

    var systemImage: String {
        switch self {
        case .arm: "shield.fill"
        case .disarm: "shield.slash"
        }
    }
}

enum PreviewError: Error {
    case failed
}

enum PreviewPlacement: String, CaseIterable {
    case plain
    case listRow
    case toolbarTop
    case toolbarBottom
}

enum PreviewAppearance {
    case light
    case dark

    var colorScheme: ColorScheme {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }
}

// MARK: - Preview chrome

private struct PreviewBackground: View {
    let appearance: PreviewAppearance

    var body: some View {
        Group {
            switch appearance {
            case .light:
                lightBackground
            case .dark:
                Color(white: 0.15)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var lightBackground: some View {
#if os(macOS)
        Color(nsColor: .windowBackgroundColor)
#elseif os(iOS)
        Color(uiColor: .systemGroupedBackground)
#else
        Color.gray.opacity(0.2)
#endif
    }
}

private var previewTopBarPlacement: ToolbarItemPlacement {
#if os(iOS)
    .principal
#else
    .automatic
#endif
}

@MainActor
@ViewBuilder
private func previewNavigationShell<Content: View, TopBar: View>(
    appearance: PreviewAppearance,
    @ViewBuilder content: () -> Content,
    @ViewBuilder topBar: () -> TopBar
) -> some View {
    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, *) {
        NavigationStack {
            ZStack {
                PreviewBackground(appearance: appearance)
                content()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: previewTopBarPlacement) {
                    topBar()
                }
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Preview")
            .toolbarBackground(.visible, for: .navigationBar)
#endif
        }
        .preferredColorScheme(appearance.colorScheme)
    }
}

@MainActor
@ViewBuilder
private func previewNavigationShell<Content: View, BottomBar: View>(
    appearance: PreviewAppearance,
    @ViewBuilder content: () -> Content,
    @ViewBuilder bottomBar: () -> BottomBar
) -> some View {
    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, *) {
        NavigationStack {
            ZStack {
                PreviewBackground(appearance: appearance)
                content()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewBottomBar {
                bottomBar()
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Preview")
#endif
        }
        .preferredColorScheme(appearance.colorScheme)
    }
}

extension View {
    @ViewBuilder
    fileprivate func previewBottomBar<Picker: View>(@ViewBuilder picker: () -> Picker) -> some View {
        #if os(iOS)
        self.toolbar {
            ToolbarItem(placement: .bottomBar) {
                picker()
            }
        }
        #else
        self.safeAreaInset(edge: .bottom, spacing: 0) {
            picker()
                .padding(.horizontal)
                .padding(.vertical, 8)
        }
        #endif
    }
}

// MARK: - Sync placement content

private struct SegmentedPickerPlacementContent: View {
    let placement: PreviewPlacement
    let appearance: PreviewAppearance

    @State private var mode = LiveOrPlayback.live

    private var picker: some View {
        SegmentedPicker(LiveOrPlayback.allCases, selection: $mode) { mode in
            Label(mode.title, systemImage: mode.systemImage)
        }
    }

    var body: some View {
        switch placement {
        case .plain:
            ZStack {
                PreviewBackground(appearance: appearance)
                VStack(spacing: 16) {
                    Text("Selected: \(mode.title)")
                    picker
                }
                .padding()
            }
            .preferredColorScheme(appearance.colorScheme)

        case .listRow:
            ZStack {
                PreviewBackground(appearance: appearance)
                List {
                    HStack {
                        Text("Mode")
                        Spacer()
                        picker
                    }
                }
            }
            .preferredColorScheme(appearance.colorScheme)

        case .toolbarTop:
            previewNavigationShell(appearance: appearance) {
                Text("Selected: \(mode.title)")
            } topBar: {
                picker
            }

        case .toolbarBottom:
            previewNavigationShell(appearance: appearance) {
                Text("Selected: \(mode.title)")
            } bottomBar: {
                picker
            }
        }
    }
}

// MARK: - Async placement content

private struct AsyncSegmentedPickerPlacementContent: View {
    let placement: PreviewPlacement
    let useIconOnly: Bool
    let appearance: PreviewAppearance

    @State private var state = ArmDisarm.arm

    private var picker: some View {
        AsyncSegmentedPicker(ArmDisarm.allCases, selection: $state) { _ in
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            if Bool.random() {
                throw PreviewError.failed
            }
        } content: { item in
            if useIconOnly {
                Label(item.title, systemImage: item.systemImage)
                    .labelStyle(.iconOnly)
            } else {
                Text(item.title)
            }
        }
    }

    var body: some View {
        switch placement {
        case .plain:
            ZStack {
                PreviewBackground(appearance: appearance)
                VStack(spacing: 16) {
                    Text("Selected: \(state.title)")
                    picker
                }
                .padding()
            }
            .preferredColorScheme(appearance.colorScheme)

        case .listRow:
            ZStack {
                PreviewBackground(appearance: appearance)
                List {
                    HStack {
                        Text("Mode")
                        Spacer()
                        picker
                    }
                }
            }
            .preferredColorScheme(appearance.colorScheme)

        case .toolbarTop:
            previewNavigationShell(appearance: appearance) {
                Text("Selected: \(state.title)")
            } topBar: {
                picker
            }

        case .toolbarBottom:
            previewNavigationShell(appearance: appearance) {
                Text("Selected: \(state.title)")
            } bottomBar: {
                picker
            }
        }
    }
}

// MARK: - Preview containers

struct SegmentedPickerPreviewContainer: View {
    let placement: PreviewPlacement
    let appearance: PreviewAppearance

    var body: some View {
        SegmentedPickerPlacementContent(placement: placement, appearance: appearance)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AsyncSegmentedPickerPreviewContainer: View {
    let placement: PreviewPlacement
    let useIconOnly: Bool
    let appearance: PreviewAppearance

    var body: some View {
        AsyncSegmentedPickerPlacementContent(
            placement: placement,
            useIconOnly: useIconOnly,
            appearance: appearance
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#endif
