// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ServerDrivenUI",
  platforms: [
    .iOS(.v18)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "ServerDrivenUI",
      targets: ["ServerDrivenUI"],
    ),
    .library(
      name: "ServerDrivenUITestHelpers",
      targets: ["ServerDrivenUITestHelpers"],
    )
  ],
  dependencies: [
    .package(name: "KDS", path: "../KDS"),
    .package(name: "GraphAPI", path: "../GraphAPI"),
    .package(name: "KsApi", path: "../KsApi"),
    .package(name: "Library", path: "../Library"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.18.6")
  ],
  targets: [
    .target(
      name: "ServerDrivenUI",
      dependencies: [
        .byName(name: "KDS"),
        .byName(name: "KsApi"),
        .byName(name: "GraphAPI")
      ]
    ),
    .target(
      name: "ServerDrivenUITestHelpers",
      dependencies: [
        .byName(name: "KDS"),
        .byName(name: "ServerDrivenUI")
      ]
    ),
    .testTarget(
      name: "ServerDrivenUITests",
      dependencies: [
        "ServerDrivenUI",
        "ServerDrivenUITestHelpers",
        .product(name: "LibraryTestHelpers", package: "Library"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
      ]
    )
  ]
)
