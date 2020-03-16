// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "HistoryView",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(
            name: "HistoryView",
            targets: ["HistoryView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/finestructure/CompArch", from: "0.7.1"),
        .package(url: "https://github.com/insidegui/MultipeerKit", from: "0.1.2"),
    ],
    targets: [
        .target(
            name: "HistoryView",
            dependencies: ["CompArch", "MultipeerKit"]),
    ]
)
