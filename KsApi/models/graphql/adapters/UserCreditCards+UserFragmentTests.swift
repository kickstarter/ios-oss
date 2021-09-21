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
      let locationFragment = GraphAPI.UserFragment.Location(
        country: "US",
        countryName: "United States",
        displayableName: "Las Vegas, NV",
        id: "TG9jYXRpb24tMjQzNjcwNA==",
        name: "Las Vegas"
      )
      let userFragment = GraphAPI.UserFragment(
        backingsCount: 3, chosenCurrency: "USD",
        email: "foo@bar.com",
        hasPassword: true,
        id: "id",
        imageUrl: "http://www.kickstarter.com/medium.jpg",
        isAppleConnected: true,
        isCreator: false,
        isDeliverable: true,
        isEmailVerified: true,
        isFollowing: false,
        location: locationFragment,
        name: "Hari Singh",
        storedCards: storedCardsFragment,
        uid: "12345"
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
        backingsCount: 3,
        chosenCurrency: "USD",
        email: "foo@bar.com",
        hasPassword: true,
        id: "id",
        imageUrl: "http://www.kickstarter.com/medium.jpg",
        isAppleConnected: true,
        isCreator: false,
        isDeliverable: true,
        isEmailVerified: true,
        isFollowing: true,
        name: "Hari Singh",
        storedCards: storedCardsFragment,
        uid: "12345"
      )

      XCTAssertTrue(UserCreditCards.userCreditCards(from: userFragment).storedCards.count == 0)
    } catch {
      XCTFail()
    }
  }
}
