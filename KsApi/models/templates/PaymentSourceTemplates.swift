import Foundation

extension Backing.PaymentSource {
  internal static let template = Backing.PaymentSource(
    expirationDate: "2019-09-30",
    id: "1",
    lastFour: "1111",
    paymentType: .creditCard,
    state: "",
    type: GraphUserCreditCard.CreditCardType.visa
  )

  internal static let visa = Backing.PaymentSource(
    expirationDate: "2019-09-30",
    id: "2",
    lastFour: "1111",
    paymentType: .creditCard,
    state: "",
    type: GraphUserCreditCard.CreditCardType.visa
  )

  internal static let applePay = Backing.PaymentSource(
    expirationDate: "2019-10-31",
    id: "1",
    lastFour: "1111",
    paymentType: .applePay,
    state: "",
    type: GraphUserCreditCard.CreditCardType.visa
  )
}
