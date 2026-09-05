// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "hardware-secret-agent-demo",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "HardwareSecretAgentCore",
            targets: ["HardwareSecretAgentCore"]
        ),
        .executable(
            name: "hardware-secret-agent-demo",
            targets: ["hardware-secret-agent-demo"]
        )
    ],
    targets: [
        .target(name: "HardwareSecretAgentCore"),
        .executableTarget(
            name: "hardware-secret-agent-demo",
            dependencies: ["HardwareSecretAgentCore"]
        ),
        .testTarget(
            name: "HardwareSecretAgentCoreTests",
            dependencies: ["HardwareSecretAgentCore"]
        )
    ]
)
