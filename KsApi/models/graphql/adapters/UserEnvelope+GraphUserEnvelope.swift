import Foundation

extension UserEnvelope {
  /**
   Returns a `UserEnvelope<GraphUser>` from a `FetchUserQuery.Data` object.
   */
  static func userEnvelope(from data: GraphAPI.FetchUserQuery.Data) -> UserEnvelope<GraphUser>? {
    guard let userFragment = data.me?.fragments.userFragment else { return nil }

    let graphUser = GraphUser(
      chosenCurrency: userFragment.chosenCurrency,
      email: userFragment.email,
      hasPassword: userFragment.hasPassword,
      id: userFragment.id,
      isCreator: userFragment.isCreator,
      imageUrl: userFragment.imageUrl,
      isAppleConnected: userFragment.isAppleConnected,
      isEmailVerified: userFragment.isEmailVerified,
      isDeliverable: userFragment.isDeliverable,
      name: userFragment.name,
      uid: userFragment.uid
    )

    return UserEnvelope<GraphUser>(me: graphUser)
  }

  /**
   Returns a `UserEnvelope<GraphUserCreditCard>` from a `FetchUserStoredCardsQuery.Data` object.
   */
  static func userEnvelope(from data: GraphAPI.FetchUserStoredCardsQuery
    .Data) -> UserEnvelope<GraphUserCreditCard>? {
    guard let storedCards = data.me?.storedCards else { return nil }
    
    guard let nodes = storedCards.nodes else { return nil }

    let creditCards = nodes.compactMap { node -> GraphUserCreditCard.CreditCard? in
      guard let node = node else { return nil }
      return GraphUserCreditCard.CreditCard(
        expirationDate: node.expirationDate,
        id: node.id,
        lastFour: node.lastFour,
        type: CreditCardType(rawValue: node.type.rawValue)
      )
    }

    let goInUserEnvelope = GraphUserCreditCard(storedCards: creditCards)

    return UserEnvelope<GraphUserCreditCard>(me: goInUserEnvelope)
  }
}
