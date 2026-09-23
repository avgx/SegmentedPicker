import SwiftUI

public struct SegmentedPicker<Data, Selection, Content>: View
where
    Data: RandomAccessCollection,
    Data.Element == Selection,
    Selection: Hashable,
    Content: View
{
    private let data: Data
    @Binding private var selection: Selection
    private let content: (Selection) -> Content

    public init(
        _ data: Data,
        selection: Binding<Selection>,
        @ViewBuilder content: @escaping (Selection) -> Content
    ) {
        self.data = data
        self._selection = selection
        self.content = content
    }

    public var body: some View {
        Picker("", selection: $selection) {
            ForEach(Array(data), id: \.self) { value in
                content(value)
                    .tag(value)
            }
        }
        .pickerStyle(.segmented)
    }
}
