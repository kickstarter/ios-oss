// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Experimentation",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Experimentation",
      targets: ["Experimentation"]
    ),
    .library(
      name: "ExperimentationTestHelpers",
      targets: ["ExperimentationTestHelpers"]
    )

  ],
  dependencies: [
    .package(url: "https://github.com/statsig-io/statsig-kit.git", from: "1.61.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Experimentation",
      dependencies: [
        .product(name: "Statsig", package: "statsig-kit")
      ]
    ),
    .target(
      name: "ExperimentationTestHelpers",
      dependencies: ["Experimentation"]
    ),
    .testTarget(
      name: "ExperimentationTests",
      dependencies: ["Experimentation"]
    )
  ]
)
