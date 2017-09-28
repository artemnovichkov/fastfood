// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Fastfood",
    products: [
        .library(name: "Fastfood", targets: ["FastfoodCore"]),
        ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/files.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FastfoodCore",
            dependencies: ["Files"],
            path: "./Sources/fastfood-core"),
        .target(
            name: "Fastfood",
            dependencies: ["FastfoodCore"]),
        .testTarget(name: "FastfoodCoreTests", dependencies: ["FastfoodCore"]),
    ]
)
