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
      "id": "VXNlci0yMDY5MTc2OTk5",
      "imageUrl": "http://www.kickstarter.com/avatar.jpg",
      "isAppleConnected": false,
      "isDeliverable": true,
      "isEmailVerified": true,
      "name": "User Name",
      "storedCards": {
        "__typename": "UserCreditCardTypeConnection",
        "storedCards": [
          {
          "__typename": "CreditCard",
            "expirationDate": "2023-01-01",
            "id": "6",
            "lastFour": "4242",
            "type": "VISA"
          }
        ],
        "totalCount": 1
      },
      "uid": "45454545"
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
      XCTAssertEqual(user.imageUrl, "http://www.kickstarter.com/avatar.jpg")
      XCTAssertEqual(user.id, "VXNlci0yMDY5MTc2OTk5")
      XCTAssertEqual(user.name, "User Name")
      XCTAssertEqual(user.uid, "45454545")
      XCTAssertEqual(true, user.hasPassword)
      XCTAssertEqual(true, user.isDeliverable)
      XCTAssertEqual(true, user.isEmailVerified)
      XCTAssertEqual(false, user.isAppleConnected)
    } catch {
      XCTFail("Failed to decode \(error)")
    }
  }

  func testDecoding_WithNilValues() {
    let jsonString = """
    {
      "chosenCurrency": null,
      "email": "blob@me.com",
      "hasPassword": null,
      "id": "VXNlci0yMDY5MTc2OTk5",
      "imageUrl": "http://www.kickstarter.com/avatar.jpg",
      "isAppleConnected": null,
      "isDeliverable": null,
      "isEmailVerified": null,
      "name": "User Name",
      "storedCards": {
        "__typename": "UserCreditCardTypeConnection",
        "storedCards": [
          {
          "__typename": "CreditCard",
            "expirationDate": "2023-01-01",
            "id": "6",
            "lastFour": "4242",
            "type": "VISA"
          }
        ],
        "totalCount": 1
      },
      "uid": "45454545"
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
      XCTAssertEqual(user.id, "VXNlci0yMDY5MTc2OTk5")
      XCTAssertEqual(user.imageUrl, "http://www.kickstarter.com/avatar.jpg")
      XCTAssertEqual(user.name, "User Name")
      XCTAssertEqual(user.uid, "45454545")
      XCTAssertNil(user.isDeliverable)
      XCTAssertNil(user.isEmailVerified)
      XCTAssertNil(user.isAppleConnected)
    } catch {
      XCTFail("Failed to decode \(error)")
    }
  }
}
