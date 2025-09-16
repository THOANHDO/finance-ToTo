// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "FinanceToTo",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "FinanceToToApp",
            targets: ["FinanceToToApp"]
        )
    ],
    targets: [
        .target(
            name: "FinanceToToApp",
            path: "Sources/FinanceToToApp",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
