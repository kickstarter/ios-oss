import Foundation
@testable import KsApi
import XCTest

private struct MyStruct: Encodable {
  let a: Int
  let b: String
  let c: C?

  struct C: Encodable {
    let a: Int
    let b: String
  }
}

final class Encodable_DictionaryTests: XCTestCase {
  func testDictionaryRepresentation() {
    let value = MyStruct(a: 1, b: "foo", c: .init(a: 2, b: "bar"))
    let dict = value.dictionaryRepresentation

    XCTAssertEqual(dict?["a"] as? Int, 1)
    XCTAssertEqual(dict?["b"] as? String, "foo")
    XCTAssertEqual((dict?["c"] as? [String: Any])?["a"] as? Int, 2)
    XCTAssertEqual((dict?["c"] as? [String: Any])?["b"] as? String, "bar")
  }

  func testDictionaryRepresentation_Nils() {
    let value = MyStruct(a: 1, b: "foo", c: nil)
    let dict = value.dictionaryRepresentation

    XCTAssertEqual(dict?["a"] as? Int, 1)
    XCTAssertEqual(dict?["b"] as? String, "foo")
    XCTAssertEqual(dict?.keys.contains("c"), .some(false))
  }
}
