import SwiftUI

public struct AsyncSegmentedPicker<Data, Selection, Content>: View
where
    Data: RandomAccessCollection,
    Data.Element == Selection,
    Selection: Hashable,
    Content: View
{
    private let data: Data
    @Binding private var selection: Selection
    private let onChange: (Selection) async throws -> Void
    private let onError: ((Error) -> Void)?
    @ViewBuilder private var content: (Selection) -> Content

    @StateObject private var coordinator: AsyncSegmentedPickerCoordinator<Selection>

    public init(
        _ data: Data,
        selection: Binding<Selection>,
        onChange: @escaping (Selection) async throws -> Void,
        onError: ((Error) -> Void)? = nil,
        @ViewBuilder content: @escaping (Selection) -> Content
    ) {
        self.data = data
        _selection = selection
        self.onChange = onChange
        self.onError = onError
        self.content = content
        _coordinator = StateObject(
            wrappedValue: AsyncSegmentedPickerCoordinator(selection: selection.wrappedValue)
        )
    }

    public var body: some View {
        SegmentedPicker(data, selection: $coordinator.displayedSelection, content: content)
            .allowsHitTesting(!coordinator.isLoading)
            .disabled(coordinator.isLoading)
            .asyncSegmentedPickerShimmer(when: coordinator.isLoading)
            .onChange(of: coordinator.displayedSelection) { newValue in
                coordinator.userChangedSelection(
                    to: newValue,
                    perform: onChange,
                    commit: { selection = $0 },
                    onError: onError
                )
            }
            .onChange(of: selection) { newValue in
                coordinator.syncFromParent(newValue)
            }
    }
}
