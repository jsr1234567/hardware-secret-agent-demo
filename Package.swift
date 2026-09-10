// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "hardware-secret-agent",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "HardwareSecretAgentCore",
            targets: ["HardwareSecretAgentCore"]
        ),
        .executable(
            name: "hardware-secret-agent",
            targets: ["hardware-secret-agent"]
        ),
        .executable(
            name: "hardware-secret-agent-demo",
            targets: ["hardware-secret-agent"]
        )
    ],
    targets: [
        .target(name: "HardwareSecretAgentCore"),
        .executableTarget(
            name: "hardware-secret-agent",
            dependencies: ["HardwareSecretAgentCore"]
        ),
        .testTarget(
            name: "HardwareSecretAgentCoreTests",
            dependencies: ["HardwareSecretAgentCore"]
        )
    ]
)
