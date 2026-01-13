// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Kickstarter-Framework",
  platforms: [
    .iOS(.v18)
  ],
  products: [
    .library(
      name: "Kickstarter-Framework",
      targets: ["Kickstarter-Framework"]
    )
  ],
  dependencies: [
    .package(path: "../KsApi"),
    .package(path: "../Library"),
    .package(url: "https://github.com/kickstarter/Kickstarter-Prelude.git", from: "1.0.0"),
    .package(url: "https://github.com/kickstarter/Kickstarter-ReactiveExtensions", from: "2.0.0"),

    .package(url: "https://github.com/Alamofire/AlamofireImage", from: "4.3.0"),
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
      name: "Kickstarter-Framework",
      dependencies: [
        .product(name: "KsApi", package: "KsApi"),
        .product(name: "Library", package: "Library"),
        .product(name: "Prelude", package: "Kickstarter-Prelude"),
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
        .product(name: "KingfisherWebP", package: "KingfisherWebP"),
        .product(name: "SegmentBrazeUI", package: "braze-segment-swift")
      ],
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "Kickstarter-Framework-Tests",
      dependencies: [
        .byName(name: "Kickstarter-Framework"),
        .product(name: "LibraryTestHelpers", package: "Library"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "ReactiveExtensions-TestHelpers", package: "Kickstarter-ReactiveExtensions")
      ],
      path: "Sources/Kickstarter-Framework-iOSTests"
    )
  ],
  swiftLanguageModes: [.v5]
)
