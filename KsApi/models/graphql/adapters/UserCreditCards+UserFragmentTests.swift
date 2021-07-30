import Apollo
@testable import KsApi
import XCTest

class UserCreditCards_UserFragmentTests: XCTestCase {
  func test_WithStoredCards() {
    let variables = ["withStoredCards": true]
    let sampleCardDict: [String: Any] = [
      "__typename": "UserCreditCardTypeConnection",
      "nodes":
        [[
          "__typename": "CreditCard",
          "expirationDate": "2025-02-01",
          "id": "69021256",
          "lastFour": "4242",
          "type": "VISA"
        ]],
      "totalCount": 1
    ]

    do {
      let storedCardsFragment = try GraphAPI.UserFragment
        .StoredCard(jsonObject: sampleCardDict, variables: variables)
      let userFragment = GraphAPI.UserFragment(
        chosenCurrency: "USD",
        email: "foo@bar.com",
        hasPassword: true,
        id: "id",
        imageUrl: "http://www.kickstarter.com/medium.jpg",
        isAppleConnected: true,
        isCreator: false,
        isDeliverable: true,
        isEmailVerified: true,
        name: "Hari Singh",
        uid: "12345",
        storedCards: storedCardsFragment
      )

      XCTAssertTrue(UserCreditCards.userCreditCards(from: userFragment).storedCards.count == 1)
    } catch {
      XCTFail()
    }
  }

  func test_WithNoStoredCards() {
    let variables = ["withStoredCards": false]
    let sampleCardDict: [String: Any] = [
      "__typename": "UserCreditCardTypeConnection",
      "nodes": [],
      "totalCount": 1
    ]

    do {
      let storedCardsFragment = try GraphAPI.UserFragment
        .StoredCard(jsonObject: sampleCardDict, variables: variables)
      let userFragment = GraphAPI.UserFragment(
        chosenCurrency: "USD",
        email: "foo@bar.com",
        hasPassword: true,
        id: "id",
        imageUrl: "http://www.kickstarter.com/medium.jpg",
        isAppleConnected: true,
        isCreator: false,
        isDeliverable: true,
        isEmailVerified: true,
        name: "Hari Singh",
        uid: "12345",
        storedCards: storedCardsFragment
      )

      XCTAssertTrue(UserCreditCards.userCreditCards(from: userFragment).storedCards.count == 0)
    } catch {
      XCTFail()
    }
  }
}
