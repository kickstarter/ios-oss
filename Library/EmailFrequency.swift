import UIKit

public enum EmailFrequency: Int {
  case daily
  case individualEmails

  public static let allCases: [EmailFrequency] = [.daily, .individualEmails]

  public static var rowHeight: CGFloat {
    return Styles.grid(7)
  }

  public var descriptionText: String {
    switch self {
    case .daily:
      return Strings.Daily_digest()
    case .individualEmails:
      return Strings.Individual_Emails()
    }
  }
}
