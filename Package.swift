// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacDaily",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "MacDaily", targets: ["MacDaily"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/MarkdownUI", from: "2.4.0"),
        .package(url: "https://github.com/JohnSundell/Splash", from: "0.16.0"),
    ],
    targets: [
        .target(name: "MacDailyCore"),
        .executableTarget(
            name: "MacDaily",
            dependencies: [
                "MacDailyCore",
                .product(name: "MarkdownUI", package: "MarkdownUI"),
                .product(name: "Splash", package: "Splash"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "MacDailyCoreTests",
            dependencies: ["MacDailyCore"]
        ),
    ]
)
