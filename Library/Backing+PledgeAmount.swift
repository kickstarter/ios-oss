import Foundation
import KsApi

extension Backing {
  /// Returns the pledge amount subtracting the shipping amount
  public var pledgeAmount: Double {
    return ksr_pledgeAmount(
      self.amount,
      subtractingShippingAmount: self.shippingAmount.flatMap(Double.init)
    )
  }

  /// Returns the bonus support amount subtracting the reward minimum from the total pledge amount
  public var bonusSupportAmount: Double {
    guard let reward = self.reward else { return 0 }

    let bonusSupportAmount = Decimal(self.pledgeAmount) - Decimal(reward.minimum)

    return (bonusSupportAmount as NSDecimalNumber).doubleValue
  }
}
