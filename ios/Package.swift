// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "auto_start_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "auto-start-flutter", targets: ["auto_start_flutter"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "auto_start_flutter",
            dependencies: [],
            path: ".",
            sources: ["Classes"],
            resources: [
                .process("Resources"),
            ]
        )
    ]
)
