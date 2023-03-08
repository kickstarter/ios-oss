import Foundation
@testable import KsApi
import XCTest

final class GraphUserEmailTests: XCTestCase {
  func testDecoding_NoNilValues() {
    let jsonString = """
    {
      "email": "blob@me.com"
    }
    """

    guard let data = jsonString.data(using: .utf8) else {
      XCTFail("JSON should be convertible to data")

      return
    }

    do {
      let user = try JSONDecoder().decode(GraphUserEmail.self, from: data)

      XCTAssertEqual(user.email, "blob@me.com")
    } catch {
      XCTFail("Failed to decode \(error)")
    }
  }

  func testDecoding_WithNilValues() {
    let jsonString = """
    {
      "email": "blob@me.com"
    }
    """

    guard let data = jsonString.data(using: .utf8) else {
      XCTFail("JSON should be convertible to data")

      return
    }

    do {
      let user = try JSONDecoder().decode(GraphUserEmail.self, from: data)

      XCTAssertEqual(user.email, "blob@me.com")
    } catch {
      XCTFail("Failed to decode \(error)")
    }
  }
}
