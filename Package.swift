// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Package configuration
let package = Package(
    name: "Mist",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "mist", targets: ["Mist"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.4"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.0.1")
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
