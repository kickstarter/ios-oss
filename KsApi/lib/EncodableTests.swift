import XCTest
@testable import KsApi

final class EncodableTests: XCTestCase {

  struct EncodableModel: EncodableType {
    let id: Int
    let name: String
    func encode() -> [String: Any] {
      return [
        "ID": self.id,
        "NAME": self.name
      ]
    }
  }

  func testToJSONString() {
    let model = EncodableModel(id: 1, name: "Blob")
    XCTAssertEqual(model.toJSONString(), "{\"ID\":1,\"NAME\":\"Blob\"}")
  }

  func testToJSONData() {
    let model = EncodableModel(id: 1, name: "Blob")
    let jsonString = "{\"ID\":1,\"NAME\":\"Blob\"}"
    let jsonData = jsonString.data(using: .utf8)

    XCTAssertEqual(model.toJSONData(), jsonData)
  }
}
