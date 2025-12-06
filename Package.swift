// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WristBop",
    platforms: [
        .watchOS(.v10),
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "WristBopCore",
            targets: ["WristBopCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.12.0")
    ],
    targets: [
        .target(
            name: "WristBopCore"
        ),
        .testTarget(
            name: "WristBopCoreTests",
            dependencies: [
                "WristBopCore",
                .product(name: "Testing", package: "swift-testing")
            ]
        )
    ]
)
