// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HabitApp6",
    platforms: [
        .macOS(.v13) // Ajusta según tu versión objetivo
    ],
    products: [
        // Ejecutable principal
        .executable(
            name: "HabitApp6",
            targets: ["HabitApp6"]
        )
    ],
    dependencies: [
        // Aquí puedes añadir dependencias externas si las necesitas
        // .package(url: "https://github.com/...", from: "1.0.0"),
    ],
    targets: [
        // Ejecutable principal
        .executableTarget(
            name: "HabitApp6",
            dependencies: [
                "Core",
                "Features",
                "Infrastructure",
                "Utils"
            ],
            path: "HabitApp6/Application"
        ),
        // Core
        .target(
            name: "Core",
            dependencies: [],
            path: "HabitApp6/Core"
        ),
        // Features
        .target(
            name: "Features",
            dependencies: ["Core"],
            path: "HabitApp6/Features"
        ),
        // Infrastructure
        .target(
            name: "Infrastructure",
            dependencies: ["Core"],
            path: "HabitApp6/Infrastructure"
        ),
        // Utils
        .target(
            name: "Utils",
            dependencies: [],
            path: "HabitApp6/Utils"
        )
    ]
)

