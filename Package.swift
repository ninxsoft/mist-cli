// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Package configuration
let package = Package(
    name: "MIST",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "mist", targets: ["MIST"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.3"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.0.1")
    ],
    targets: [
        .executableTarget(
            name: "MIST",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams")
            ],
            path: "MIST"
        )
    ]
)
