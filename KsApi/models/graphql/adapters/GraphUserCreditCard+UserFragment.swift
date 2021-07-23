import Foundation

extension GraphUserCreditCard {
  /**
   Returns an optional `GraphUserCreditCard` from a `GraphAPI.UserStoredCardsFragment`
   */
  static func graphUserCreditCard(from userStoredCardsFragment: GraphAPI
    .UserStoredCardsFragment) -> GraphUserCreditCard? {
    guard let storedCards = userStoredCardsFragment.storedCards,
      let nodes = storedCards.nodes else { return nil }

    let creditCards = nodes.compactMap { node -> CreditCard? in
      guard let node = node else { return nil }
      return CreditCard(
        expirationDate: node.expirationDate,
        id: node.id,
        lastFour: node.lastFour,
        type: CreditCardType(rawValue: node.type.rawValue)
      )
    }

    return GraphUserCreditCard(storedCards: creditCards)
  }
}
