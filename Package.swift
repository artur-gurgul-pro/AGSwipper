// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AGSwipper",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "AGSwipper",
            targets: ["AGSwipper"]),
    ],
    targets: [
        .target(
            name: "AGSwipper"),
        .testTarget(
            name: "AGSwipperTests",
            dependencies: ["AGSwipper"]
        ),
    ]
)
