// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ColorScript",
  targets: [
    .target(
      name: "ColorScript",
      dependencies: ["ColorScriptCore"]
    ),
    .target(name: "ColorScriptCore"),
    .testTarget(name: "ColorScriptTests", dependencies: ["ColorScriptCore"])
  ]
)
