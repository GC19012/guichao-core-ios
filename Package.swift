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
            checksum: "b6b63008ac571534835c3eb66dc83ac11ddcbbde2f275a7609036f7c488d19d4"
        ),
    ]
)
