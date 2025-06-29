// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "macnav",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "macnav", targets: ["macnav"])
    ],
    dependencies: [
        // Dependencies will be added here later
    ],
    targets: [
        .executableTarget(
            name: "macnav",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "macnavTests",
            dependencies: ["macnav"],
            path: "Tests"
        )
    ]
)