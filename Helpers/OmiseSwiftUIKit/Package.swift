// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OmiseSwiftUIKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "OmiseSwiftUIKit",
            type: .dynamic,
            targets: ["OmiseSwiftUIKit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OmiseSwiftUIKit",
            dependencies: []),
        .testTarget(
            name: "OmiseSwiftUIKitTests",
            dependencies: ["OmiseSwiftUIKit"])
    ]
)
