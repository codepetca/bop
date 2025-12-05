// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WristBop",
    platforms: [
        .watchOS(.v10),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "WristBopCore",
            targets: ["WristBopCore"]
        )
    ],
    targets: [
        .target(
            name: "WristBopCore"
        ),
        .testTarget(
            name: "WristBopCoreTests",
            dependencies: ["WristBopCore"]
        )
    ]
)
