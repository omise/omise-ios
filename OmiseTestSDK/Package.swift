// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OmiseTestSDK",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "OmiseTestSDK",
            type: .dynamic,
            targets: ["OmiseTestSDK"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OmiseTestSDK",
            dependencies: []),
        .testTarget(
            name: "OmiseTestSDKTests",
            dependencies: ["OmiseTestSDK"],
            resources: [
                .process("Resources")
            ])
    ]
)
