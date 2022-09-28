// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "WordsCore",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "WordsCore",
            targets: [
                "WordsCore",
            ]
        ),
    ],
    targets: [
        .target(name: "WordsCore"),        
        .testTarget(
            name: "WordsCoreTests",
            dependencies: ["WordsCore"]
        )
    ]
)
