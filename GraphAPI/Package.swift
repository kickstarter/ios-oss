// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "GraphAPI",
  platforms: [
    .iOS(.v18),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5),
  ],
  products: [
    .library(name: "GraphAPI", targets: ["GraphAPI"]),
    .library(name: "GraphAPITestMocks", targets: ["GraphAPITestMocks"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "GraphAPI",
      dependencies: [
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ],
      path: "./Sources"
    ),
    .target(
      name: "GraphAPITestMocks",
      dependencies: [
        .product(name: "ApolloTestSupport", package: "apollo-ios"),
        .target(name: "GraphAPI"),
      ],
      path: "./GraphAPITestMocks"
    ),
  ]
)
