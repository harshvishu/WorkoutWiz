// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FrameworksAndDrivers",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "Persistence", targets: ["Persistence"]),
        .library(name: "Preferences", targets: ["Preferences"]),
        .library(name: "UI", targets: ["UI"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../ApplicationServices"),
        .package(path: "../DesignSystem"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.17.0"), // Firebase
        .package(url: "https://github.com/exyte/PopupView.git", from: "2.8.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "Persistence",
                dependencies: ["Domain", "ApplicationServices",
                               .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                               .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
                               .product(name: "FirebaseDatabaseSwift", package: "firebase-ios-sdk"),
                               .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                               .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
                               .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                ],
                resources: [.copy("Resources/exercises.json")]),
        .target(name: "Preferences", dependencies: ["Domain", "ApplicationServices"]),
        .target(name: "UI",
                dependencies: ["Domain", "ApplicationServices", "DesignSystem", "Persistence",
                               .product(name: "PopupView", package: "PopupView")],
                resources: [.process("Resources/Assets.xcassets")]),
        .testTarget(name: "FrameworksAndDriversTests", dependencies: ["Persistence", "Preferences", "UI"]),
    ]
)
