// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OmiseUnitTestKit",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "OmiseUnitTestKit",
            type: .dynamic,
            targets: ["OmiseUnitTestKit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OmiseUnitTestKit",
            dependencies: []),
        .testTarget(
            name: "OmiseUnitTestKitTests",
            dependencies: ["OmiseUnitTestKit"])
    ]
)
