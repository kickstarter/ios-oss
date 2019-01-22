import Foundation
import XCTest
import ColorScriptCore
import ColorScript

final class ColorScriptTests: XCTestCase {

  var path: URL? {
    return FileManager.default.urls(
      for: .documentDirectory,
       in: .userDomainMask
      )[0].appendingPathComponent("ios-oss/bin/ColorScript/Resources/Colors.json")
  }

  var data: Data {
    guard let path = self.path else {
      XCTFail("Couldn't find json file")
      return Data()
    }
    return try! Data(contentsOf: path)
  }

  func testDataIsNotNil() {

    let colors = Color(data: data)
    XCTAssertNotNil(colors.colors)
  }

  func testColorNameFormat() {
    let colors = Color(data: data)
    colors.allColors.forEach { (arg: (key: String, value: [(key: Int, value: String)])) in

      let (key, value) = arg
      let colorName = key.lowercased()
      let weight = value.first!.key
      let formattedName = weight > 0 ? "ksr_\(colorName.replacingOccurrences(of: " ", with: "_"))_\(weight)" :
                                       "ksr_\(colorName.replacingOccurrences(of: " ", with: "_"))"

      XCTAssertEqual(
        value.first?.value, formattedName
      )
    }
  }

  static var allTests = [
      ("testDataIsNotNil", testDataIsNotNil)
  ]
}
