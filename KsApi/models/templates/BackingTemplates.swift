import Foundation
import Prelude

extension Backing {
  internal static let template = Backing(
    addOns: [.template],
    amount: 10.00,
    backer: .template,
    backerId: 1,
    backerCompleted: true,
    bonusAmount: 0,
    cancelable: true,
    id: 1,
    locationId: 1,
    locationName: "United States",
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

  internal static let errored = Backing.template |> Backing.lens.status .~ .errored
}
