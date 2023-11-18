// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DeunaSDK",
    platforms: [
           .iOS(.v11)  // This specifies that the package is compatible with iOS 13 and later versions
       ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DeunaSDK",
            targets: ["DeunaSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/deuna-developers/deuna-ios-client", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DeunaSDK", 
            dependencies: ["deuna-ios-client", ],
            path: "Sources/DeunaSDK"),
        .testTarget(
            name: "DeunaSDKTests",
            dependencies: ["DeunaSDK"]),
    ]
)
