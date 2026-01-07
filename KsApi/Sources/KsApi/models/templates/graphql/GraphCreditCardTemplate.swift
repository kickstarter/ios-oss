import Foundation

extension UserCreditCards {
  public static let masterCard = UserCreditCards.CreditCard(
    expirationDate: "2018-10-31",
    id: "1",
    lastFour: "0000",
    type: .mastercard,
    stripeCardId: "pm_fake_masterCard"
  )

  public static let visa = UserCreditCards.CreditCard(
    expirationDate: "2019-09-30",
    id: "2",
    lastFour: "1111",
    type: .visa,
    stripeCardId: "pm_fake_visa"
  )

  public static let diners = UserCreditCards.CreditCard(
    expirationDate: "2022-09-01",
    id: "3",
    lastFour: "1212",
    type: .diners,
    stripeCardId: "pm_fake_diners"
  )

  public static let jcb = UserCreditCards.CreditCard(
    expirationDate: "2022-01-01",
    id: "4",
    lastFour: "2222",
    type: .jcb,
    stripeCardId: "pm_fake_jcb"
  )

  public static let discover = UserCreditCards.CreditCard(
    expirationDate: "2022-03-12",
    id: "5",
    lastFour: "4242",
    type: .discover,
    stripeCardId: "pm_fake_discover"
  )

  public static let amex = UserCreditCards.CreditCard(
    expirationDate: "2024-01-12",
    id: "6",
    lastFour: "8882",
    type: .amex,
    stripeCardId: "pm_fake_amex"
  )

  public static let generic = UserCreditCards.CreditCard(
    expirationDate: "2024-01-12",
    id: "7",
    lastFour: "1882",
    type: .generic,
    stripeCardId: "pm_fake_generic"
  )

  public static let unionPay = UserCreditCards.CreditCard(
    expirationDate: "2021-11-10",
    id: "8",
    lastFour: "0005",
    type: .unionPay,
    stripeCardId: "pm_fake_unionPay"
  )

  public static let template = UserCreditCards(
    storedCards: [
      UserCreditCards.amex,
      UserCreditCards.masterCard,
      UserCreditCards.visa,
      UserCreditCards.diners,
      UserCreditCards.jcb,
      UserCreditCards.discover,
      UserCreditCards.unionPay,
      UserCreditCards.generic
    ]
  )

  public static let emptyTemplate = UserCreditCards(
    storedCards: []
  )

  public static func withCards(_ cards: [UserCreditCards.CreditCard]) -> UserCreditCards {
    return UserCreditCards(storedCards: cards)
  }
}
