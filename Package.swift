// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NetworkProvider",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "NetworkProvider", targets: ["NetworkProvider"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "NetworkProvider", dependencies: [])
    ]
)
