#if DEBUG
import SwiftUI

#Preview("Live Playback Plain Light") {
    SegmentedPickerPreviewContainer(placement: .plain, appearance: .light)
}

#Preview("Live Playback Plain Dark") {
    SegmentedPickerPreviewContainer(placement: .plain, appearance: .dark)
}

#Preview("Live Playback List Row Light") {
    SegmentedPickerPreviewContainer(placement: .listRow, appearance: .light)
}

#Preview("Live Playback List Row Dark") {
    SegmentedPickerPreviewContainer(placement: .listRow, appearance: .dark)
}

#Preview("Live Playback Toolbar Top Light") {
    SegmentedPickerPreviewContainer(placement: .toolbarTop, appearance: .light)
}

#Preview("Live Playback Toolbar Top Dark") {
    SegmentedPickerPreviewContainer(placement: .toolbarTop, appearance: .dark)
}

#Preview("Live Playback Toolbar Bottom Light") {
    SegmentedPickerPreviewContainer(placement: .toolbarBottom, appearance: .light)
}

#Preview("Live Playback Toolbar Bottom Dark") {
    SegmentedPickerPreviewContainer(placement: .toolbarBottom, appearance: .dark)
}

#endif
