// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EmojiPicker",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "EmojiPicker",
            targets: ["EmojiPicker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pxlshpr/ViewSugar", from: "0.0.1"),
        .package(url: "https://github.com/pxlshpr/SearchableView", from: "0.0.1"),
        .package(url: "https://github.com/pxlshpr/FormSugar", from: "0.0.11"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "EmojiPicker",
            dependencies: [
                .product(name: "ViewSugar", package: "viewsugar"),
                .product(name: "SearchableView", package: "searchableview"),
                .product(name: "FormSugar", package: "formsugar"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "EmojiPickerTests",
            dependencies: ["EmojiPicker"]),
    ]
)
