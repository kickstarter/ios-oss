import Foundation
import KsApi

extension GraphUserCreditCard.CreditCard {

  public func expirationDate() -> String {
    return formatted(dateString: self.formattedExpirationDate)
  }

  public func lastFourShortStyle() -> String {
    return Strings.Card_ending_in_last_four(last_four: self.lastFour)
  }

  private func formatted(dateString: String) -> String {
    let date = toDate(dateString: dateString)
    return Format.date(
      secondsInUTC: date.timeIntervalSince1970,
      template: "MM-yyyy",
      timeZone: UTCTimeZone
    )
  }

  private func toDate(dateString: String) -> Date {
    // Always use UTC timezone here this date should be timezone agnostic
    guard let date = Format.date(
      from: dateString,
      dateFormat: "yyyy-MM",
      timeZone: UTCTimeZone
      ) else {
        fatalError("Unable to parse date format")
    }

    return date
  }
}
