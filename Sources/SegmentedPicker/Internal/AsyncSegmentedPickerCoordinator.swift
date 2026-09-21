import SwiftUI

@MainActor
final class AsyncSegmentedPickerCoordinator<Selection: Hashable & Sendable>: ObservableObject {
    @Published var displayedSelection: Selection
    @Published private(set) var isLoading = false

    private var committedSelection: Selection
    private var task: Task<Void, Never>?

    init(selection: Selection) {
        displayedSelection = selection
        committedSelection = selection
    }

    func syncFromParent(_ selection: Selection) {
        guard !isLoading else { return }
        displayedSelection = selection
        committedSelection = selection
    }

    func userChangedSelection(
        to newValue: Selection,
        perform: @escaping (Selection) async throws -> Void,
        commit: @escaping (Selection) -> Void,
        onError: ((Error) -> Void)?
    ) {
        guard !isLoading else { return }
        guard newValue != committedSelection else { return }

        let previous = committedSelection
        isLoading = true

        task?.cancel()
        task = Task {
            do {
                try await perform(newValue)
                guard !Task.isCancelled else { return }
                committedSelection = newValue
                commit(newValue)
            } catch {
                guard !Task.isCancelled else { return }
                displayedSelection = previous
                onError?(error)
            }
            isLoading = false
        }
    }
}
