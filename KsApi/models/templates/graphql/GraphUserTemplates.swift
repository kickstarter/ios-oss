import Foundation

extension GraphUser {
  internal static let template = GraphUser(
    chosenCurrency: "USD",
    email: "user@example.com",
    hasPassword: true,
    id: "idString=",
    isBlocked: false,
    imageUrl: "http://www.example.com/image.jpg",
    isAppleConnected: false,
    isEmailVerified: true,
    isDeliverable: true,
    name: "Backer McGee",
    storedCards: UserCreditCards.withCards([
      UserCreditCards.visa,
      UserCreditCards.masterCard
    ]),
    uid: "12345"
  )
}
