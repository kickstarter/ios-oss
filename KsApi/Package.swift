// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KsApi",
  platforms: [
    .iOS(.v18)
  ],
  products: [
    .library(
      name: "KsApi",
      targets: ["KsApi"]
    ),
    .library(
      name: "KsApiTestHelpers",
      targets: ["KsApiTestHelpers"]
    )
  ],
  dependencies: [
    .package(path: "../GraphAPI"),
    .package(url: "https://github.com/apollographql/apollo-ios.git", .exact("1.9.3")),
    .package(url: "https://github.com/kickstarter/Kickstarter-Prelude.git", from: "1.0.0"),
    .package(url: "https://github.com/kickstarter/Kickstarter-ReactiveExtensions", from: "2.0.0"),
    .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.4.3")
  ],
  targets: [
    .target(
      name: "KsApi",
      dependencies: [
        .product(name: "Prelude", package: "Kickstarter-Prelude"),
        .product(name: "SwiftSoup", package: "SwiftSoup"),
        .product(name: "ReactiveExtensions", package: "Kickstarter-ReactiveExtensions"),

        .product(name: "Apollo", package: "apollo-ios"),

        .product(name: "GraphAPI", package: "GraphAPI")
      ]
    ),
    .target(
      name: "KsApiTestHelpers",
      dependencies: [
        .product(name: "GraphAPI", package: "GraphAPI"),
        .product(name: "Apollo", package: "apollo-ios"),
        .byName(name: "KsApi")
      ]
    ),
    .testTarget(
      name: "KsApiTests",
      dependencies: [
        .byName(name: "KsApi"),
        .byName(name: "KsApiTestHelpers"),
        .product(name: "GraphAPI", package: "GraphAPI"),
        .product(name: "GraphAPITestMocks", package: "GraphAPI"),
        .product(name: "ReactiveExtensions-TestHelpers", package: "Kickstarter-ReactiveExtensions")
      ],
      resources: [
        .process("queries/templates/")
      ]
    )
  ],
  swiftLanguageModes: [.v5]
)
