import UIKit

extension PledgePaymentIncrementState {
  // TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
  public var description: String {
    switch self {
    case .collected: return "Collected"
    case .unattemped: return "Unattemped"
    case .unknown: return "Unknown"
    }
  }

  public var badgeColor: UIColor {
    switch self {
    case .collected: .ksr_create_100
    case .unattemped: .ksr_support_200
    case .unknown: .ksr_celebrate_100
    }
  }

  public var badgeForegroundColor: UIColor {
    switch self {
    case .collected: .ksr_create_700
    case .unattemped: .ksr_support_400
    case .unknown: .ksr_support_400
    }
  }
}
