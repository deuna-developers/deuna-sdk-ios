// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DeunaSDK",
    platforms: [
           .iOS(.v13)  // This specifies that the package is compatible with iOS 13 and later versions
       ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DeunaSDK",
            targets: ["DeunaSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/deuna-developers/deuna-ios-client", .upToNextMajor(from: "1.4.11")),
        .package(url: "https://github.com/Riskified/riskified_ios_sdk.git", .upToNextMajor(from: "1.6.4"))
    ],
    targets: [
        .binaryTarget(
            name: "RLTMXProfiling",
            path: "Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfiling.xcframework"
        ),
        .binaryTarget(
            name: "RLTMXProfilingCompanion",
            path: "Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfiling-companion.xcframework"
        ),
        .binaryTarget(
            name: "RLTMXProfilingConnections",
            path: "Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfilingConnections.xcframework"
        ),
        .binaryTarget(
            name: "RLTMXProfilingConnectionsCompanion",
            path: "Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfilingConnections-companion.xcframework"
        ),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DeunaSDK", 
            dependencies: [
                "deuna-ios-client",
                .product(name: "RiskifiedBeacon", package: "riskified_ios_sdk"),
                "RLTMXProfiling",
                "RLTMXProfilingCompanion",
                "RLTMXProfilingConnections",
                "RLTMXProfilingConnectionsCompanion"
            ],
            path: "Sources/DeunaSDK"),
        .testTarget(
            name: "DeunaSDKTests",
            dependencies: ["DeunaSDK"]),
    ]
)
