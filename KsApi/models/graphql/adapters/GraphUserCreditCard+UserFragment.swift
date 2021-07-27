import Foundation

extension GraphUserCreditCard {
  /**
   Returns a `GraphUserCreditCard` from a `GraphAPI.UserFragment`
   */
  static func graphUserCreditCard(from userFragment: GraphAPI.UserFragment) -> GraphUserCreditCard {
    guard let storedCards = userFragment.storedCards?.fragments.userStoredCardsFragment.nodes else {
      return GraphUserCreditCard(storedCards: [])
    }

    let allCards = storedCards.compactMap { card -> GraphUserCreditCard.CreditCard? in
      guard let node = card else { return nil }

      return GraphUserCreditCard.CreditCard(
        expirationDate: node.expirationDate,
        id: node.id,
        lastFour: node.lastFour,
        type: CreditCardType(rawValue: node.type.rawValue)
      )
    }

    return GraphUserCreditCard(storedCards: allCards)
  }
}
