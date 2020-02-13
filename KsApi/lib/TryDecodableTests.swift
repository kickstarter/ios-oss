import Argo
import Curry
import Foundation
import KsApi
import Runes
import XCTest

struct MyArgoModel: Argo.Decodable, Equatable {
  public let id: Int
  public let name: String
  public let model: MySwiftModel

  static func decode(_ json: JSON) -> Decoded<MyArgoModel> {
    return curry(MyArgoModel.init)
      <^> json <| "id"
      <*> json <| "name"
      <*> ((json <| "model" >>- tryDecodable) as Decoded<MySwiftModel>)
  }
}

struct MySwiftModel: Swift.Decodable, Equatable {
  public let array: [String]
  public let bool: Bool
  public let dict: [String: String]
  public let id: Int
  public let name: String
}

final class TryDecodableTests: XCTestCase {
  func testTryDecodable() {
    let data: [String: Any] = [
      "id": 1,
      "name": "Argo Name",
      "model": [
        "array": ["string1", "string2"],
        "bool": true,
        "dict": ["key1": "value1", "key2": "value2"],
        "id": 5,
        "name": "Swift Name"
      ]
    ]

    let argoDecoded = MyArgoModel.decodeJSONDictionary(data)

    let expected = MyArgoModel(
      id: 1,
      name: "Argo Name",
      model: MySwiftModel(
        array: ["string1", "string2"],
        bool: true,
        dict: ["key1": "value1", "key2": "value2"],
        id: 5,
        name: "Swift Name"
      )
    )

    XCTAssertEqual(argoDecoded.value, expected)
  }
}
