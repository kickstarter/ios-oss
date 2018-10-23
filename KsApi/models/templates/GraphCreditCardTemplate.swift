import Foundation

extension GraphUserCreditCard {

  internal static let template = GraphUserCreditCard(
    storedCards: CreditCardConnection(nodes: [GraphUserCreditCard.CreditCard(expirationDate: "2018-10-31",
                                                                             id: "1",
                                                                             lastFour: "0000",
                                                                             type: "MASTERCARD")]))
}
