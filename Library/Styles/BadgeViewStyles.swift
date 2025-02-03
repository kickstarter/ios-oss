import UIKit

public enum BadgeStyle: Equatable {
  case success
  case neutral
  case error
  case custom(foregroundColor: UIColor, backgroundColor: UIColor)
}

extension BadgeStyle {
  public var foregroundColor: UIColor {
    switch self {
    case .success: return .ksr_create_700
    case .neutral: return .ksr_support_500
    case .error: return .ksr_alert
    case let .custom(foregroundColor, _): return foregroundColor
    }
  }

  public var backgroundColor: UIColor {
    switch self {
    case .success: return .ksr_create_100
    case .neutral: return .ksr_support_100
    case .error: return .ksr_alert.withAlphaComponent(0.1)
    case let .custom(_, backgroundColor): return backgroundColor
    }
  }
}
