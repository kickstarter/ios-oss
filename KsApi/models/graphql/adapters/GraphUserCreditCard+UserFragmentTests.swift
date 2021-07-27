import Apollo
@testable import KsApi
import XCTest

class GraphUserCreditCard_UserFragmentTests: XCTestCase {
  func test() {
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
        id: GraphQLID(),
        imageUrl: "http://www.kickstarter.com/medium.jpg",
        isAppleConnected: true,
        isCreator: false,
        isDeliverable: true,
        isEmailVerified: true,
        name: "Hari Singh",
        uid: "12345",
        storedCards: storedCardsFragment
      )

      XCTAssertTrue(GraphUserCreditCard.graphUserCreditCard(from: userFragment).storedCards.count == 1)
    } catch {
      print("*** \(error.localizedDescription)")
      XCTFail()
    }
  }
}
