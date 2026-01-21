// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Library",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v18),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5)
  ],
  products: [
    .library(
      name: "Library",
      targets: ["Library"]
    ),
    .library(
      name: "LibraryTestHelpers",
      targets: ["LibraryTestHelpers"]
    )
  ],
  dependencies: [
    .package(path: "../KsApi"),
    .package(path: "../KDS"),
    .package(url: "https://github.com/kickstarter/Kickstarter-Prelude.git", from: "1.0.0"),
    .package(url: "https://github.com/kickstarter/Kickstarter-ReactiveExtensions", from: "2.0.0"),

    .package(url: "https://github.com/Alamofire/AlamofireImage", from: "4.3.0"),
    .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.5.1"),
    .package(url: "https://github.com/braze-inc/braze-segment-swift", from: "6.0.0"),
    .package(url: "https://github.com/facebook/facebook-ios-sdk", from: "12.0.0"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.4.0"),
    .package(url: "https://github.com/onevcat/Kingfisher", from: "8.5.0"),
    .package(url: "https://github.com/stripe/stripe-ios-spm", from: "23.32.0"),
    .package(url: "https://github.com/yeatse/KingfisherWebP.git", from: "1.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.6")

  ],
  targets: [
    .target(
      name: "Library",
      dependencies: [
        .product(name: "KsApi", package: "KsApi"),
        .product(name: "KDS", package: "KDS"),
        .product(name: "Prelude_UIKit", package: "Kickstarter-Prelude"),
        .product(name: "AlamofireImage", package: "AlamofireImage"),
        .product(name: "Kingfisher", package: "Kingfisher"),
        .product(name: "FacebookCore", package: "facebook-ios-sdk"),
        .product(name: "FacebookLogin", package: "facebook-ios-sdk"),
        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
        .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
        .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
        .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
        .product(name: "Stripe", package: "stripe-ios-spm"),
        .product(name: "StripePaymentSheet", package: "stripe-ios-spm"),
        .product(name: "Prelude", package: "Kickstarter-Prelude"),
        .product(name: "KingfisherWebP", package: "KingfisherWebP"),
        .product(name: "Lottie", package: "lottie-ios"),
        .product(name: "SegmentBrazeUI", package: "braze-segment-swift")
      ],
      path: "Sources/Library",
      resources: [
        .process("Resources"),
      ],
    ),
    .target(
      name: "LibraryTestHelpers",
      dependencies: [
        .byName(name: "Library"),
        .product(name: "KsApiTestHelpers", package: "KsApi"),
      ],
      path: "Sources/LibraryTestHelpers"
    ),
    .testTarget(
      name: "Library-Tests",
      dependencies: [
        .byName(name: "Library"),
        .byName(name: "LibraryTestHelpers"),
        .product(name: "KsApiTestHelpers", package: "KsApi"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "ReactiveExtensions-TestHelpers", package: "Kickstarter-ReactiveExtensions")
      ],
      path: "Sources/LibraryTests"
    )
  ],
  swiftLanguageModes: [.v5]
)
