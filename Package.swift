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
        .package(url: "https://github.com/ios-3ds-sdk/SPM", .exact("2.4.0")),
        .package(url: "https://github.com/omise/omise-flutter-wrapper-ios", from: "0.4.1")
    ],
    targets: [
        .target(
            name: "OmiseSDK",
            dependencies: [
                .product(name: "ThreeDS_SDK", package: "SPM"),
                .product(name: "OmiseFlutterSPM", package: "omise-flutter-wrapper-ios")
            ],
            path: "OmiseSDK",
            exclude: ["Info.plist"],
            resources: [.process("Resources")]
        )
    ]
)
