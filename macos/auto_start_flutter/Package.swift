// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "auto_start_flutter",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        .library(name: "auto-start-flutter", targets: ["auto_start_flutter"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "auto_start_flutter",
            dependencies: [],
            resources: [
                .process("Resources"),
            ]
        )
    ]
)
