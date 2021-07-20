import Foundation

extension GraphUserCreditCard {
  /**
   Returns a `GraphUserCreditCard` from a `GraphAPI.UserFragment`
   */
  static func graphUserCreditCard(from userFragment: GraphAPI.UserFragment) -> GraphUserCreditCard? {
    guard let storedCards = userFragment.storedCards,
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

    return GraphUserCreditCard(nodes: creditCards)
  }
}
