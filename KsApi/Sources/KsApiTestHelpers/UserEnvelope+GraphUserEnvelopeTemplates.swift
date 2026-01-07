import GraphAPI
@testable import KsApi

public struct GraphUserEnvelopeTemplates {
  static let fetchUserEmail = GraphAPI.FetchUserEmailQuery.Data(
    me: GraphAPI.FetchUserEmailQuery.Data.Me(
      email: "user@example.com"
    )
  )

  static let fetchUser = GraphAPI.FetchUserQuery.Data(
    me: GraphAPI.FetchUserQuery.Data.Me(
      backingsCount: 0,
      chosenCurrency: nil,
      email: "user@example.com",
      hasPassword: true,
      id: "fakeId",
      imageUrl: "https://i.kickstarter.com/missing_user_avatar.png",
      isAppleConnected: false,
      isBlocked: false,
      isCreator: false,
      isDeliverable: true,
      isEmailVerified: true,
      isFollowing: false,
      name: "Example User",
      storedCards: GraphAPI.FetchUserQuery.Data.Me.StoredCards(nodes: [
        GraphAPI.UserStoredCardsFragment.Node(
          expirationDate: "2023-01-01",
          id: "6",
          lastFour: "4242",
          type: .case(GraphAPI.CreditCardTypes.visa),
          stripeCardId: "pm_1OtGFX4VvJ2PtfhK3Gp00SWK"
        )
      ], totalCount: 1),
      uid: "11111"
    )
  )
}
