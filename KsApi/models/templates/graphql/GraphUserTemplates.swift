import Foundation

extension GraphUser {
  internal static let template = GraphUser(
    chosenCurrency: "USD",
    email: "nativesquad@ksr.com",
    hasPassword: true,
    id: "VXNlci0xNTQ2MjM2ODI=",
    imageUrl: "http://www.kickstarter.com/image.jpg",
    isAppleConnected: false,
    isEmailVerified: true,
    isDeliverable: true,
    name: "Backer McGee",
    storedCards: GraphUserCreditCard(storedCards: GraphUserCreditCard
      .CreditCardConnection(nodes: [GraphUserCreditCard.CreditCard(
        expirationDate: "2024-02-21",
        id: "100",
        lastFour: "4242",
        type: .amex
      )])),
    uid: "12345"
  )
}
