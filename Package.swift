// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "OmiseSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v11)
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
            name: "OmiseSDKObjc",
            path: "OmiseSDKObjc",
            publicHeadersPath: ""
        ),
        .target(
            name: "OmiseSDK",
            dependencies: ["OmiseSDKObjc"],
            path: "OmiseSDK",
            exclude: ["Info.plist", "OmiseSDK.h"],
            resources: [.process("Resources")]
        )
    ]
)
