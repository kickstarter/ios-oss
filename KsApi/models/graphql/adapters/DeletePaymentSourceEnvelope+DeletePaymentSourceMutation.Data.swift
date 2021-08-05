import Foundation
import ReactiveSwift

extension DeletePaymentMethodEnvelope {
  static func from(_ data: GraphAPI.DeletePaymentSourceMutation.Data) -> DeletePaymentMethodEnvelope? {
    guard let storedCards = data.paymentSourceDelete?.user?.storedCards?.fragments.userStoredCardsFragment
      .nodes else {
      return nil
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

    return DeletePaymentMethodEnvelope(storedCards: allCards)
  }

  static func producer(from data: GraphAPI.DeletePaymentSourceMutation
    .Data) -> SignalProducer<DeletePaymentMethodEnvelope, ErrorEnvelope> {
    guard let envelope = DeletePaymentMethodEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
