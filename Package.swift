// swift-tools-version:6.3.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Package configuration
let package: Package = .init(
    name: "Mist",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "mist", targets: ["Mist"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.8.2"),
        // .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.61.1"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.63.1"),
        .package(url: "https://github.com/jpsim/Yams", from: "6.2.2")
    ],
    targets: [
        .executableTarget(
            name: "Mist",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams")
            ],
            path: "Mist"
        ),
        .testTarget(
            name: "MistTests",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams")
            ],
            path: "MistTests"
        )
    ]
)
