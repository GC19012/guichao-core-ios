// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GuiChaoCoreKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "GuiChaoCoreKit", targets: ["GuiChaoCore"]),
    ],
    targets: [
        .binaryTarget(
            name: "GuiChaoCore",
            url: "https://github.com/GC19012/guichao-core-ios/releases/download/3.1.8/GuiChaoCore.xcframework.zip",
            checksum: "<REPLACE_WITH_OUTPUT_OF_compute-checksum>"
        ),
    ]
)
