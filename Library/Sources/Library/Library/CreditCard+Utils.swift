import Foundation
import KsApi

extension UserCreditCards.CreditCard {
  public func expirationDate() -> String {
    return self.formatted(dateString: self.formattedExpirationDate)
  }

  private func formatted(dateString: String) -> String {
    let date = self.toDate(dateString: dateString)
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
