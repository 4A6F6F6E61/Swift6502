// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swift6502",
    products: [
        .executable(name: "emulator", targets: ["emulator"]),
        .library(name: "CPUCore", targets: ["CPUCore"]),
    ],
    targets: [
        .target(
            name: "CPUCore",
            dependencies: []
        ),
        .executableTarget(
            name: "emulator",
            dependencies: ["CPUCore"]
        ),
        .testTarget(
            name: "CPUCoreTests",
            dependencies: ["CPUCore"]
        ),
    ]
)
