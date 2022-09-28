// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "WordsCore",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "WordsCore",
            targets: [
                "Domain",
                "WordsGenerator",
                "WordsGeneratorImpl",
                "GameInteraction",
                "GameScene",
                "GameOverScene"
            ]
        ),
    ],
    targets: [
        .target(name: "Domain"),
        .target(
            name: "WordsGenerator",
            dependencies: ["Domain"]
        ),
        .target(
            name: "WordsGeneratorImpl",
            dependencies: ["Domain", "WordsGenerator"],
            resources: [.copy("Resources/words.json")]
        ),
        .target(
            name: "GameInteraction",
            dependencies: ["Domain", "WordsGenerator"]
        ),
        .target(
            name: "GameScene",
            dependencies: [
                "Domain",
                "WordsGenerator",
                "GameInteraction"
            ]
        ),
        .target(
            name: "GameOverScene",
            dependencies: ["Domain"]
        ),
        .testTarget(
            name: "GameInteractionTests",
            dependencies: ["Domain", "GameInteraction", "WordsGenerator"]
        )
    ]
)
