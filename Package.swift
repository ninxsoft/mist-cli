// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MIST",
    platforms: [
        .macOS(.v10_10)
    ],
    products: [
        .executable(name: "mist", targets: ["MIST"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.4"),
        .package(url: "https://github.com/jpsim/Yams", from: "4.0.6")
    ],
    targets: [
        .target(name: "MIST", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Yams", package: "Yams")
        ], path: "MIST")
    ]
)
