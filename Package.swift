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
    dependencies: [
        .package(url: "https://github.com/ios-3ds-sdk/SPM", .exact("2.4.0")),
        .package(url: "https://github.com/tyler-techcombine/flutter-ios-framework-spm.git", .branch("main"))
    ],
    targets: [
        .target(
            name: "OmiseSDK",
            dependencies: [
                .product(name: "ThreeDS_SDK", package: "SPM"),
                .product(name: "omise-flutter-ios-spm", package: "flutter-ios-framework-spm")
            ],
            path: "OmiseSDK",
            exclude: ["Info.plist"],
            resources: [.process("Resources")]
        )
    ]
)
