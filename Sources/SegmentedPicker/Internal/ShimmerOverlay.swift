import SwiftUI

struct ShimmerOverlay: View {
    private let duration: TimeInterval = 1.2

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { context in
            let phase = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: duration) / duration

            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height

                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .white.opacity(0.4), location: 0.5),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: width * 0.55, height: height)
                .offset(x: -width * 0.35 + phase * (width * 1.35))
            }
            .clipShape(Capsule())
        }
        .background(.ultraThinMaterial.opacity(0.35), in: .capsule)
        .allowsHitTesting(true)
    }
}

extension View {
    func asyncSegmentedPickerShimmer(when isLoading: Bool) -> some View {
        overlay {
            if isLoading {
                ShimmerOverlay()
                    .clipShape(Capsule())
            }
        }
    }
}
