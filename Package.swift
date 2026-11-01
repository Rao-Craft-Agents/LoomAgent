// swift-tools-version:6.0
// LoomAgent: Loom's social-app UI (posts, comments, people, communities, feeds, compose) as plain SwiftUI any social
// app can use, written into an app from its own types, as a Granite agent package. An app that links it finds the
// `loom` agent through Granite's roster, with nothing listed by hand.

import PackageDescription

let package = Package(
    name: "LoomAgent",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LoomAgent", targets: ["LoomAgent"]),
    ],
    dependencies: [
        .package(url: "https://github.com/riteshpakala/Granite.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "LoomAgent",
            dependencies: [.product(name: "GraniteAgents", package: "Granite")],
            swiftSettings: [.swiftLanguageMode(.v6)]),
        .testTarget(
            name: "LoomAgentTests",
            dependencies: ["LoomAgent", .product(name: "GraniteAgents", package: "Granite")],
            swiftSettings: [.swiftLanguageMode(.v6)]),
    ]
)
