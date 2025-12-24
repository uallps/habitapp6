// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "HabitApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "HabitApp6", targets: ["HabitApp6"])
    ],
    targets: [
        .executableTarget(
            name: "HabitApp6",
            path: "Sources/habitapp6",
            exclude: [],
            sources: nil,
            resources: []
        )
    ]
)
