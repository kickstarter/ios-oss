import Foundation

extension GraphUserCreditCard {

  public static let masterCard = GraphUserCreditCard.CreditCard(expirationDate: "2018-10-31",
                                                                id: "1",
                                                                lastFour: "0000",
                                                                type: "MASTERCARD")

  public static let visa = GraphUserCreditCard.CreditCard(expirationDate: "2019-09-30",
                                                          id: "2",
                                                          lastFour: "1111",
                                                          type: "VISA")

  public static let diners = GraphUserCreditCard.CreditCard(expirationDate: "2022-09-01",
                                                            id: "3",
                                                            lastFour: "1212",
                                                            type: "DINERS")

  public static let jcb = GraphUserCreditCard.CreditCard(expirationDate: "2022-01-01",
                                                         id: "4",
                                                         lastFour: "2222",
                                                         type: "JCB")

  public static let discover = GraphUserCreditCard.CreditCard(expirationDate: "2022-03-12",
                                                              id: "5",
                                                              lastFour: "4242",
                                                              type: "DISCOVER")

  public static let amex = GraphUserCreditCard.CreditCard(expirationDate: "2024-01-12",
                                                          id: "6",
                                                          lastFour: "8882",
                                                          type: "AMEX")

  public static let generic = GraphUserCreditCard.CreditCard(expirationDate: "2024-01-12",
                                                             id: "7",
                                                             lastFour: "1882",
                                                             type: "----")

  public static let template = GraphUserCreditCard(
    storedCards: CreditCardConnection(nodes: [GraphUserCreditCard.amex,
                                              GraphUserCreditCard.masterCard,
                                              GraphUserCreditCard.visa,
                                              GraphUserCreditCard.diners,
                                              GraphUserCreditCard.jcb,
                                              GraphUserCreditCard.discover,
                                              GraphUserCreditCard.generic]))

  public static let emptyTemplate = GraphUserCreditCard(
    storedCards: CreditCardConnection(nodes: []))
}
