import Foundation
@testable import KsApi
import XCTest

final class GraphUserTests: XCTestCase {
  func testDecoding_NoNilValues() {
    let jsonString = """
    {
      "chosenCurrency": "USD",
      "email": "blob@me.com",
      "hasPassword": true,
      "isAppleConnected": false,
      "isDeliverable": true,
      "isEmailVerified": true
    }
    """

    guard let data = jsonString.data(using: .utf8) else {
      XCTFail("JSON should be convertible to data")

      return
    }

    do {
      let user = try JSONDecoder().decode(GraphUser.self, from: data)

      XCTAssertEqual(user.email, "blob@me.com")
      XCTAssertEqual(user.chosenCurrency, "USD")
      XCTAssertEqual(true, user.hasPassword)
      XCTAssertEqual(true, user.isDeliverable)
      XCTAssertEqual(true, user.isEmailVerified)
      XCTAssertEqual(false, user.isAppleConnected)
    } catch {
      XCTFail("Failed to decode GraphUserCreditCard")
    }
  }

  func testDecoding_WithNilValues() {
    let jsonString = """
    {
      "chosenCurrency": null,
      "email": "blob@me.com",
      "hasPassword": null,
      "isAppleConnected": null,
      "isDeliverable": null,
      "isEmailVerified": null
    }
    """

    guard let data = jsonString.data(using: .utf8) else {
      XCTFail("JSON should be convertible to data")

      return
    }

    do {
      let user = try JSONDecoder().decode(GraphUser.self, from: data)

      XCTAssertEqual(user.email, "blob@me.com")
      XCTAssertNil(user.chosenCurrency)
      XCTAssertNil(user.hasPassword)
      XCTAssertNil(user.isDeliverable)
      XCTAssertNil(user.isEmailVerified)
      XCTAssertNil(user.isAppleConnected)
    } catch {
      XCTFail("Failed to decode GraphUserCreditCard")
    }
  }
}
