// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SegmentedPicker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .tvOS(.v18),
        .macOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SegmentedPicker",
            targets: ["SegmentedPicker"]
        ),
    ],
    targets: [
        .target(
            name: "SegmentedPicker"
        ),
        .testTarget(
            name: "SegmentedPickerTests",
            dependencies: ["SegmentedPicker"]
        ),
    ]
)
