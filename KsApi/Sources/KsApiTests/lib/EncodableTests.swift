@testable import KsApi
import XCTest

final class EncodableTests: XCTestCase {
  struct EncodableModel: EncodableType {
    let name: String
    func encode() -> [String: Any] {
      return [
        "NAME": self.name
      ]
    }
  }

  func testToJSONString() {
    let model = EncodableModel(name: "Blob")
    XCTAssertEqual(model.toJSONString(), "{\"NAME\":\"Blob\"}")
  }

  func testToJSONData() {
    let model = EncodableModel(name: "Blob")
    let jsonString = "{\"NAME\":\"Blob\"}"
    let jsonData = jsonString.data(using: .utf8)

    XCTAssertEqual(model.toJSONData(), jsonData)
  }
}
