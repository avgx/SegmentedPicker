import Foundation
import Testing
@testable import SegmentedPicker

@Test @MainActor func asyncCoordinatorCommitsOnSuccess() async {
    let coordinator = AsyncSegmentedPickerCoordinator(selection: "ARM")
    var committed = "ARM"

    coordinator.displayedSelection = "DISARM"
    coordinator.userChangedSelection(
        to: "DISARM",
        perform: { _ in },
        commit: { committed = $0 },
        onError: nil
    )

    try? await Task.sleep(nanoseconds: 50_000_000)

    #expect(coordinator.displayedSelection == "DISARM")
    #expect(committed == "DISARM")
    #expect(coordinator.isLoading == false)
}

@Test @MainActor func asyncCoordinatorRollsBackOnFailure() async {
    let coordinator = AsyncSegmentedPickerCoordinator(selection: "ARM")
    enum TestError: Error { case boom }

    coordinator.displayedSelection = "DISARM"
    coordinator.userChangedSelection(
        to: "DISARM",
        perform: { _ in throw TestError.boom },
        commit: { _ in },
        onError: nil
    )

    try? await Task.sleep(nanoseconds: 50_000_000)

    #expect(coordinator.displayedSelection == "ARM")
    #expect(coordinator.isLoading == false)
}

@Test @MainActor func asyncCoordinatorIgnoresChangeWhileLoading() async {
    let coordinator = AsyncSegmentedPickerCoordinator(selection: "ARM")

    coordinator.displayedSelection = "DISARM"
    coordinator.userChangedSelection(
        to: "DISARM",
        perform: { _ in try await Task.sleep(nanoseconds: NSEC_PER_SEC) },
        commit: { _ in },
        onError: nil
    )

    #expect(coordinator.isLoading == true)

    coordinator.userChangedSelection(
        to: "ARM",
        perform: { _ in },
        commit: { _ in },
        onError: nil
    )

    #expect(coordinator.displayedSelection == "DISARM")
}
