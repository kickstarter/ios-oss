import Foundation

extension GraphUserCreditCard {
  public static let masterCard = GraphUserCreditCard.CreditCard(
    expirationDate: "2018-10-31",
    id: "1",
    lastFour: "0000",
    paymentType: .card,
    state: nil,
    type: .mastercard
  )

  public static let visa = GraphUserCreditCard.CreditCard(
    expirationDate: "2019-09-30",
    id: "2",
    lastFour: "1111",
    paymentType: .card,
    state: nil,
    type: .visa
  )

  public static let diners = GraphUserCreditCard.CreditCard(
    expirationDate: "2022-09-01",
    id: "3",
    lastFour: "1212",
    paymentType: .card,
    state: nil,
    type: .diners
  )

  public static let jcb = GraphUserCreditCard.CreditCard(
    expirationDate: "2022-01-01",
    id: "4",
    lastFour: "2222",
    paymentType: .card,
    state: nil,
    type: .jcb
  )

  public static let discover = GraphUserCreditCard.CreditCard(
    expirationDate: "2022-03-12",
    id: "5",
    lastFour: "4242",
    paymentType: .card,
    state: nil,
    type: .discover
  )

  public static let amex = GraphUserCreditCard.CreditCard(
    expirationDate: "2024-01-12",
    id: "6",
    lastFour: "8882",
    paymentType: .card,
    state: nil,
    type: .amex
  )

  public static let generic = GraphUserCreditCard.CreditCard(
    expirationDate: "2024-01-12",
    id: "7",
    lastFour: "1882",
    paymentType: .card,
    state: nil,
    type: .generic
  )

  public static let unionPay = GraphUserCreditCard.CreditCard(
    expirationDate: "2021-11-10",
    id: "8",
    lastFour: "0005",
    paymentType: .card,
    state: nil,
    type: .unionPay
  )

  public static let applePay = GraphUserCreditCard.CreditCard(
    expirationDate: "2024-01-12",
    id: "6",
    lastFour: "8882",
    paymentType: .applePay,
    state: nil,
    type: nil
  )

  public static let template = GraphUserCreditCard(
    storedCards: CreditCardConnection(nodes: [
      GraphUserCreditCard.amex,
      GraphUserCreditCard.masterCard,
      GraphUserCreditCard.visa,
      GraphUserCreditCard.diners,
      GraphUserCreditCard.jcb,
      GraphUserCreditCard.discover,
      GraphUserCreditCard.generic,
      GraphUserCreditCard.unionPay,
      GraphUserCreditCard.applePay
    ])
  )

  public static let emptyTemplate = GraphUserCreditCard(
    storedCards: CreditCardConnection(nodes: [])
  )
}
