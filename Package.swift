// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "OmiseSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "OmiseSDK",
            type: .dynamic,
            targets: ["OmiseSDK"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/netceteragroup/ios-3ds-sdk-spm", .exact("2.4.0"))
    ],
    targets: [
        .target(
            name: "OmiseSDK",
            dependencies: [
                .product(name: "ThreeDS_SDK", package: "ios-3ds-sdk-spm")
            ],
            path: "OmiseSDK",
            exclude: ["Info.plist"],
            resources: [.process("Resources")]
        )
    ]
)
