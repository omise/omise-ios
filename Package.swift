// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "OmiseSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "OmiseSDK",
            type: .dynamic,
            targets: ["OmiseSDK"]
        )
    ],
    targets: [
        .target(
            name: "OmiseSDK",
            dependencies: [],
            path: "OmiseSDK",
            exclude: ["Info.plist"],
            resources: [.process("Resources")]
        )
    ]
)
