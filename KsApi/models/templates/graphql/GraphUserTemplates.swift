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
    storedCards: UserCreditCards.withCards([
      UserCreditCards.visa,
      UserCreditCards.masterCard
    ]),
    uid: "12345"
  )
}
