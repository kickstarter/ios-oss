import UIKit

public enum EmailFrequency: Int {
  case dailySummary
  case twiceADaySummary

  public static let allCases: [EmailFrequency] = [.dailySummary, .twiceADaySummary]

  public static var rowHeight: CGFloat {
    return Styles.grid(7)
  }

  public var descriptionText: String {
    switch self {
    case .dailySummary:
      return Strings.Daily_summary()
    case .twiceADaySummary:
      return Strings.Twice_a_day_summary()
    }
  }
}
