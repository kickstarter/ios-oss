import Foundation
@testable import KsApi
import XCTest

struct Foo: Decodable {
  var bar: Int
  var baz: String?
}

final class DecodeErrorTests: XCTestCase {
  func test_decodeError_missingKey() {
    let json = """
      {
          "baz": "Hello"
      }
    """

    do {
      let data = json.data(using: .utf8)!
      _ = try JSONDecoder().decode(Foo.self, from: data)
      XCTFail("Decode should have thrown")
    } catch let error as DecodingError {
      XCTAssertEqual(error.prettyDescription, "JSON decoding failed: missing key \"bar\"")
    } catch {
      XCTFail("Threw the wrong error")
    }
  }

  func test_decodeError_missingValue() {
    let json = """
      {
          "bar": null,
          "baz": "Hello"
      }
    """

    do {
      let data = json.data(using: .utf8)!
      _ = try JSONDecoder().decode(Foo.self, from: data)
      XCTFail("Decode should have thrown")
    } catch let error as DecodingError {
      XCTAssertEqual(error.prettyDescription, "JSON decoding failed: missing value for \"bar\"")
    } catch {
      XCTFail("Threw the wrong error")
    }
  }

  func test_decodeError_typeMismatch() {
    let json = """
      {
          "bar": "Hello",
          "baz": "Hello"
      }
    """

    do {
      let data = json.data(using: .utf8)!
      _ = try JSONDecoder().decode(Foo.self, from: data)
      XCTFail("Decode should have thrown")
    } catch let error as DecodingError {
      XCTAssertEqual(error.prettyDescription, "JSON decoding failed: type mismatch for \"bar\"")
    } catch {
      XCTFail("Threw the wrong error")
    }
  }
}
