// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KsApi",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "KsApi",
      targets: ["KsApi"]
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
    .testTarget(
      name: "KsApiTests",
      dependencies: [
        .byName(name: "KsApi"),
        .product(name: "GraphAPI", package: "GraphAPI"),
        .product(name: "GraphAPITestMocks", package: "GraphAPI"),
        .product(name: "ReactiveExtensions-TestHelpers", package: "Kickstarter-ReactiveExtensions")
      ],
      resources: [
        .process("queries/templates/")
      ]
    ),
  ]
)
