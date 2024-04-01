// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EventSourcingPractice",
    platforms: [
        .macOS(.v13 )
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EventSourcingPractice",
            targets: ["EventSourcingPractice"])
    ],
    dependencies: [
        .package(url: "https://github.com/gradyzhuo/EventStoreDB-Swift.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EventSourcingPractice", dependencies: [ 
                .product(name: "EventStoreDB", package: "eventstoredb-swift")
            ]),
        .executableTarget(name: "ESDB", dependencies: ["EventSourcingPractice"]),
        .executableTarget(name: "InMemory", dependencies: ["EventSourcingPractice"]),
        .testTarget(
            name: "EventSourcingPracticeTests",
            dependencies: ["EventSourcingPractice"]),
    ]
)
