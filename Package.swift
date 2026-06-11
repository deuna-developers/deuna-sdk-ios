// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "DeunaSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // ── Core SDK ─────────────────────────────────────────────────────────────
        // Include ONLY this product if you do not use generateFraudId,
        // or if your fraud provider is not listed below.
        .library(
            name: "DeunaSDK",
            targets: ["DeunaSDK"]
        ),

        // ── Optional fraud provider products ────────────────────────────────────
        // Add the product(s) that match the fraud providers you pass to generateFraudId.
        // DeunaSDK detects each provider at runtime — no code changes required.

        /// Cybersource / LexisNexis ThreatMetrix (RLTMXProfiling)
        .library(
            name: "DeunaSDKCybersource",
            targets: ["_DeunaSDKCybersource"]
        ),

        /// Kount (KountSDK)
        .library(
            name: "DeunaSDKKount",
            targets: ["_DeunaSDKKount"]
        ),

        /// Sift Science (sift-ios)
        .library(
            name: "DeunaSDKSift",
            targets: ["_DeunaSDKSift"]
        ),

        /// Riskified (RiskifiedBeacon)
        .library(
            name: "DeunaSDKRiskified",
            targets: ["_DeunaSDKRiskified"]
        ),

        /// Signifyd (TMXProfiling — non-branded ThreatMetrix)
        .library(
            name: "DeunaSDKSignifyd",
            targets: ["_DeunaSDKSignifyd"]
        ),

        /// Accertify (InMobileMME)
        .library(
            name: "DeunaSDKAccertify",
            targets: ["_DeunaSDKAccertify"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/deuna-developers/deuna-ios-client",   .upToNextMajor(from: "1.4.11")),
        .package(url: "https://github.com/Riskified/riskified_ios_sdk.git",     .upToNextMajor(from: "1.6.4")),
        .package(url: "https://github.com/SiftScience/sift-ios.git",            .upToNextMajor(from: "2.2.5")),
    ],
    targets: [
        // ── Vendored binary targets ──────────────────────────────────────────────
        .binaryTarget(
            name: "KountSDK",
            path: "Sources/DeunaSDK/Vendor/Kount/KountSDK.xcframework"
        ),
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

        .binaryTarget(
            name: "TMXProfiling",
            path: "Sources/DeunaSDK/Vendor/Signifyd/TMXProfiling.xcframework"
        ),
        .binaryTarget(
            name: "TMXProfilingConnections",
            path: "Sources/DeunaSDK/Vendor/Signifyd/TMXProfilingConnections.xcframework"
        ),

        .binaryTarget(
            name: "InMobileMME",
            path: "Sources/DeunaSDK/Vendor/Accertify/InMobileMME.xcframework"
        ),

        // ── ObjC bridge: NSException catcher ────────────────────────────────────
        // Provides DeunaPerformSafely() — wraps ObjC calls in @try/@catch so
        // that NSExceptions thrown by third-party SDKs (e.g. TMXProfiling on
        // invalid orgId) are caught and surfaced as log warnings instead of crashes.
        .target(
            name: "_DeunaSDKObjCBridge",
            path: "Sources/_DeunaSDKObjCBridge",
            publicHeadersPath: "include"
        ),

        // ── Core SDK target ──────────────────────────────────────────────────────
        // Zero fraud SDK dependencies. Fraud providers are detected at runtime
        // via NSClassFromString — they are only linked when the integrator
        // adds the corresponding DeunaSDKXxx product.
        .target(
            name: "DeunaSDK",
            dependencies: [
                .product(name: "deuna-ios-client", package: "deuna-ios-client"),
                "_DeunaSDKObjCBridge",
            ],
            path: "Sources/DeunaSDK",
            exclude: ["Vendor"]
        ),

        // ── Thin linker targets (one per fraud provider) ─────────────────────────
        // These targets contain no business logic. Their sole purpose is to pull
        // the fraud framework into the integrator's binary so DeunaSDK can find
        // it via reflection at runtime.

        .target(
            name: "_DeunaSDKCybersource",
            dependencies: [
                "RLTMXProfiling",
                "RLTMXProfilingCompanion",
                "RLTMXProfilingConnections",
                "RLTMXProfilingConnectionsCompanion",
            ],
            path: "Sources/_DeunaSDKCybersource"
        ),

        .target(
            name: "_DeunaSDKKount",
            dependencies: ["KountSDK"],
            path: "Sources/_DeunaSDKKount"
        ),

        .target(
            name: "_DeunaSDKSift",
            dependencies: [
                .product(name: "sift-ios", package: "sift-ios"),
            ],
            path: "Sources/_DeunaSDKSift"
        ),

        .target(
            name: "_DeunaSDKRiskified",
            dependencies: [
                .product(name: "RiskifiedBeacon", package: "riskified_ios_sdk"),
            ],
            path: "Sources/_DeunaSDKRiskified"
        ),

        .target(
            name: "_DeunaSDKSignifyd",
            dependencies: [
                "TMXProfiling",
                "TMXProfilingConnections",
            ],
            path: "Sources/_DeunaSDKSignifyd"
        ),

        .target(
            name: "_DeunaSDKAccertify",
            dependencies: [
                "InMobileMME",
            ],
            path: "Sources/_DeunaSDKAccertify"
        ),

        // ── Tests ────────────────────────────────────────────────────────────────
        .testTarget(
            name: "DeunaSDKTests",
            dependencies: ["DeunaSDK"]
        ),
    ]
)
