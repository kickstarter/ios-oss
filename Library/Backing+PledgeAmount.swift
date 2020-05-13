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
}
