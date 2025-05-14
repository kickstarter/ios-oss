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
    case .success: return LegacyColors.ksr_create_700.uiColor()
    case .neutral: return LegacyColors.ksr_support_500.uiColor()
    case .error: return LegacyColors.ksr_alert.uiColor()
    case let .custom(foregroundColor, _): return foregroundColor
    }
  }

  public var backgroundColor: UIColor {
    switch self {
    case .success: return LegacyColors.ksr_create_100.uiColor()
    case .neutral: return LegacyColors.ksr_support_100.uiColor()
    case .error: return LegacyColors.ksr_alert.uiColor().withAlphaComponent(0.1)
    case let .custom(_, backgroundColor): return backgroundColor
    }
  }
}
