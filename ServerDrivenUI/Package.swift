// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ServerDrivenUI",
    platforms: [
      .iOS(.v18),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ServerDrivenUI",
            targets: ["ServerDrivenUI"],
        ),
    ],
    dependencies: [
      .package(name: "KDS", path: "../KDS"),
      .package(name: "GraphAPI", path: "../GraphAPI"),
    ],
    targets: [
        .target(
          name: "ServerDrivenUI",
          dependencies: [
            .byName(name: "KDS"),
            .byName(name: "GraphAPI"),
          ]
        ),
        .testTarget(
            name: "ServerDrivenUITests",
            dependencies: ["ServerDrivenUI"]
        ),
    ]
)
