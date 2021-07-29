import Foundation

extension UserCreditCards {
  /**
   Returns a `UserCreditCards` from a `GraphAPI.UserFragment`
   */
  static func userCreditCards(from userFragment: GraphAPI.UserFragment) -> UserCreditCards {
    guard let storedCards = userFragment.storedCards?.fragments.userStoredCardsFragment.nodes else {
      return UserCreditCards(storedCards: [])
    }

    let allCards = storedCards.compactMap { card -> UserCreditCards.CreditCard? in
      guard let node = card else { return nil }

      return UserCreditCards.CreditCard(
        expirationDate: node.expirationDate,
        id: node.id,
        lastFour: node.lastFour,
        type: CreditCardType(rawValue: node.type.rawValue)
      )
    }

    return UserCreditCards(storedCards: allCards)
  }
}
