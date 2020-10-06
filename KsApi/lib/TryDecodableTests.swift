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

struct SingleValueArgoModel: Argo.Decodable, Equatable {
  public let id: Int
  public let name: String
  public let model: SingleValueSwiftModel

  static func decode(_ json: JSON) -> Decoded<SingleValueArgoModel> {
    return curry(SingleValueArgoModel.init)
      <^> json <| "id"
      <*> json <| "name"
      <*> ((json <| "model" >>- tryDecodable) as Decoded<SingleValueSwiftModel>)
  }
}

struct SingleValueSwiftModel: Codable, Equatable {
  public let k_bool: Bool
  public let k_int: Int
  public let k_int8: Int8
  public let k_int16: Int16
  public let k_int32: Int32
  public let k_int64: Int64
  public let k_uint: UInt
  public let k_uint8: UInt8
  public let k_uint16: UInt16
  public let k_uint32: UInt32
  public let k_uint64: UInt64
  public let k_string: String
  public let k_double: Double
  public let k_float: Float
  public let k_nil: String?
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

  func testTryDecodablePrimitiveTypes() {
    let data: [String: Any?] = [
      "id": 2,
      "name": "Argo Name",
      "model": [
        "k_bool": true,
        "k_int": Int(1),
        "k_int8": Int8(8),
        "k_int16": Int16(16),
        "k_int32": Int32(32),
        "k_int64": Int64(64),
        "k_uint": UInt(1),
        "k_uint8": UInt8(8),
        "k_uint16": UInt16(16),
        "k_uint32": UInt32(32),
        "k_uint64": UInt64(64),
        "k_string": "string",
        "k_double": Double(1.1),
        "k_float": Float(1.2),
        "k_nil": nil
      ]
    ]

    let argoDecoded = SingleValueArgoModel.decodeJSONDictionary(data as [String: Any])

    let expected = SingleValueArgoModel(
      id: 2,
      name: "Argo Name",
      model: SingleValueSwiftModel(
        k_bool: true,
        k_int: Int(1),
        k_int8: Int8(8),
        k_int16: Int16(16),
        k_int32: Int32(32),
        k_int64: Int64(64),
        k_uint: UInt(1),
        k_uint8: UInt8(8),
        k_uint16: UInt16(16),
        k_uint32: UInt32(32),
        k_uint64: UInt64(64),
        k_string: "string",
        k_double: Double(1.1),
        k_float: Float(1.2),
        k_nil: nil
      )
    )

    XCTAssertEqual(argoDecoded.value, expected)
  }

  func testTryDecodableMissingKeyError() {
    let data: [String: Any?] = [
      "id": 3,
      "name": "Missing Key"
    ]

    let argoDecoded = SingleValueArgoModel.decodeJSONDictionary(data as [String: Any])

    XCTAssertNil(argoDecoded.value, "decoded value should be nil")
    XCTAssert(argoDecoded.error == DecodeError.missingKey("model"))
  }

  func testTryDecodableTypeMismatchError() {
    let data: [String: Any?] = [
      "id": 4,
      "name": "value",
      "model": [
        "array": ["string1", "string2"],
        "bool": true,
        "dict": ["key1": "value1", "key2": "value2"],
        "id": "wrong type",
        "name": "Swift Name"
      ]
    ]

    let argoDecoded = MyArgoModel.decodeJSONDictionary(data as [String: Any])

    XCTAssertNil(argoDecoded.value, "decoded value should be nil")
    switch argoDecoded.error! {
    case DecodeError.custom:
      XCTAssertTrue(true, "custom error type expected")
    default:
      XCTAssertTrue(false, "custom error type expected")
    }
  }
}
