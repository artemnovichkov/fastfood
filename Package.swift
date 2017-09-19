// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "fastfood",
    dependencies: [
        .package(url: "https://github.com/johnsundell/files.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FastfoodCore",
            dependencies: ["Files"],
            path: "./Sources/fastfood-core"),
        .target(
            name: "fastfood",
            dependencies: ["FastfoodCore"]),
    ]
)
