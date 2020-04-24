import Foundation

extension Backing.PaymentSource {
  internal static let template = Backing.PaymentSource(
    expirationDate: "2019-09-30",
    id: "1",
    lastFour: "1111",
    paymentType: .creditCard,
    state: "",
    type: CreditCardType.visa
  )

  internal static let visa = Backing.PaymentSource(
    expirationDate: "2019-09-30",
    id: "2",
    lastFour: "1111",
    paymentType: .creditCard,
    state: "",
    type: CreditCardType.visa
  )

  internal static let amex = Backing.PaymentSource(
    expirationDate: "2019-09-30",
    id: "6",
    lastFour: "8882",
    paymentType: .creditCard,
    state: "",
    type: CreditCardType.amex
  )

  internal static let applePay = Backing.PaymentSource(
    expirationDate: "2019-10-31",
    id: "1",
    lastFour: "1111",
    paymentType: .applePay,
    state: "",
    type: CreditCardType.visa
  )

  internal static let googlePay = Backing.PaymentSource(
    expirationDate: "2019-10-31",
    id: "123",
    lastFour: "4111",
    paymentType: .googlePay,
    state: "ACTIVE", type: .visa
  )
}
