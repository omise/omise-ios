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
        .package(url: "https://github.com/omise/omise-ios-3ds.git", .exact("2.4.0"))
    ],
    targets: [
        .target(
            name: "OmiseSDK",
            dependencies: [
                .product(name: "ThreeDS_SDK", package: "omise-ios-3ds")
            ],
            path: "OmiseSDK",
            exclude: ["Info.plist"],
            resources: [.process("Resources")]
        )
    ]
)
