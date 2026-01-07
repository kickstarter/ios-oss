import Foundation
import KsApi

public struct PledgePaymentIncrementFormatted: Equatable {
  public var incrementChargeNumber: String
  public var amount: String
  public var scheduledCollection: String

  init(from increment: PledgePaymentIncrement, index: Int) {
    let chargeNumber = String(index + 1)
    self.incrementChargeNumber = Strings.Charge_number(number: chargeNumber)
    self.amount = increment.amount.amountFormattedInProjectNativeCurrency
    self.scheduledCollection = getDateFormatted(increment.scheduledCollection)
  }
}

private func getDateFormatted(_ timeStamp: TimeInterval) -> String {
  Format.date(
    secondsInUTC: timeStamp,
    dateStyle: .medium,
    timeStyle: .none
  )
}
