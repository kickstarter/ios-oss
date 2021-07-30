import Foundation
import ReactiveSwift

extension CreatePaymentSourceEnvelope {
  static func from(_ data: GraphAPI.CreatePaymentSourceMutation.Data) -> CreatePaymentSourceEnvelope? {
    guard let createdPaymentSource = data.createPaymentSource,
      createdPaymentSource.isSuccessful,
      let rawCreditCardData = createdPaymentSource.paymentSource?.fragments.creditCardFragment.asCreditCard,
      let rawCardType = CreditCardType(rawValue: rawCreditCardData.type.rawValue) else {
      return nil
    }

    let creditCard = UserCreditCards.CreditCard(
      expirationDate: rawCreditCardData.expirationDate,
      id: rawCreditCardData.id,
      lastFour: rawCreditCardData.lastFour,
      type: rawCardType
    )

    let paymentSource = CreatePaymentSource(
      isSuccessful: createdPaymentSource.isSuccessful,
      paymentSource: creditCard
    )

    return CreatePaymentSourceEnvelope(createPaymentSource: paymentSource)
  }

  static func producer(from data: GraphAPI.CreatePaymentSourceMutation
    .Data) -> SignalProducer<CreatePaymentSourceEnvelope, ErrorEnvelope> {
    guard let envelope = CreatePaymentSourceEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
