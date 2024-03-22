// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ApplicationServices",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "ApplicationServices", targets: ["ApplicationServices"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.9.2")    // swift-composable-architecture
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ApplicationServices",
            dependencies: [
                "Domain",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(name: "ApplicationServicesTests", dependencies: ["ApplicationServices"]),
    ]
)
