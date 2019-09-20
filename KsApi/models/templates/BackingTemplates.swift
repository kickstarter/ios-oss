import Foundation

extension Backing {
  internal static let template = Backing(
    amount: 10.00,
    backer: .template,
    backerId: 1,
    backerCompleted: true,
    id: 1,
    locationId: 1,
    paymentSource: .template,
    pledgedAt: Date(timeIntervalSince1970: 1_475_361_315).timeIntervalSince1970,
    projectCountry: "US",
    projectId: 1,
    reward: .template,
    rewardId: 1,
    sequence: 10,
    shippingAmount: 2,
    status: .pledged
  )
}

extension Backing.PaymentSource {
  internal static let template = Backing.PaymentSource(
    expirationDate: "09/19/2019",
    id: 1,
    lastFour: "1234",
    paymentType: "APPLE_PAY",
    state: "ACTIVE",
    type: "MASTERCARD"
  )
}
