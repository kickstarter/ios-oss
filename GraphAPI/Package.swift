// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "GraphAPI",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5),
  ],
  products: [
    .library(name: "GraphAPI", type: .dynamic, targets: ["GraphAPI"]),
    .library(name: "GraphAPITestMocks", type: .dynamic, targets: ["GraphAPITestMocks"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "GraphAPI",
      dependencies: [
        .product(name: "Apollo-Dynamic", package: "apollo-ios"),
      ],
      path: "./Sources"
    ),
    .target(
      name: "GraphAPITestMocks",
      dependencies: [
        .product(name: "ApolloTestSupport", package: "apollo-ios"),
      ],
      path: "./GraphAPITestMocks"
    ),
  ]
)
