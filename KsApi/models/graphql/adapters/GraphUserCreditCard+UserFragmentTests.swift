import Apollo
@testable import KsApi
import XCTest

class GraphUserCreditCard_UserFragmentTests: XCTestCase {
  func test() {
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
      storedCards: GraphAPI.UserFragment
        .StoredCard(
          nodes: [
            GraphAPI.UserFragment.StoredCard
              .Node(
                expirationDate: "2023-01-01",
                id: "123456",
                lastFour: "4242",
                type: .visa
              )
          ],
          totalCount: 1
        ),
      uid: "12345"
    )

    XCTAssertNotNil(GraphUserCreditCard.graphUserCreditCard(from: userFragment))
  }
}
