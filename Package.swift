// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "OTPManager",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "OTPManager", targets: ["OTPManager"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "OTPManager",
            dependencies: [],
            path: "Sources/OTPManager",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "OTPManagerTests",
            dependencies: ["OTPManager"],
            path: "Tests/OTPManagerTests"
        )
    ]
)
