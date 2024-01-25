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
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),
    ],
    targets: [
        .target(name: "NetworkProvider", dependencies: []),
        .testTarget(name: "NetworkProviderTests", dependencies: ["NetworkProvider", "Quick", "Nimble"]),
    ]
)
