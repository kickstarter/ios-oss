import Foundation
import XCTest
import ColorScriptCore

final class ColorScriptTests: XCTestCase {
  func testDataIsNotNil() {

    let inPath = "../../../../../Design/Colors.json"
    let outPath = "Library/Styles/Colors.swift"

    let data = try! Data(contentsOf: URL(fileURLWithPath: inPath))
    let colors = Color(data: data)

    XCTAssertNotNil(colors.colors)
  }

  func testExample() throws {
      // This is an example of a functional test case.
      // Use XCTAssert and related functions to verify your tests produce the correct
      // results.

      // Some of the APIs that we use below are available in macOS 10.13 and above.
      guard #available(macOS 10.13, *) else {
          return
      }

      let fooBinary = productsDirectory.appendingPathComponent("ColorScriptExecutable")

      let process = Process()
      process.executableURL = fooBinary

      let pipe = Pipe()
      process.standardOutput = pipe

      try process.run()
      process.waitUntilExit()

      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      let output = String(data: data, encoding: .utf8)

      XCTAssertEqual(output, "Hello, world!\n")
  }

  /// Returns path to the built products directory.
  var productsDirectory: URL {
    #if os(macOS)
      for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
          return bundle.bundleURL.deletingLastPathComponent()
      }
      fatalError("couldn't find the products directory")
    #else
      return Bundle.main.bundleURL
    #endif
  }

  static var allTests = [
      ("testExample", testExample), ("testDataIsNotNil", testDataIsNotNil)
  ]
}
