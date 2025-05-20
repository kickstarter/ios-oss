import UIKit

/// Defines legacy button styles using the `KSRButtonStyleConfiguration` protocol.
///
/// These styles are used as fallback or for buttons that do not have equivalents in the new design system.
public enum KSRButtonLegacyStyle: KSRButtonStyleConfiguration, CaseIterable {
  case blue
  case grey

  public var backgroundColor: UIColor {
    switch self {
    case .blue: LegacyColors.ksr_trust_500.uiColor()
    case .grey: LegacyColors.ksr_support_300.uiColor()
    }
  }

  public var highlightedBackgroundColor: UIColor {
    switch self {
    case .blue: LegacyColors.ksr_trust_500.uiColor().mixDarker(0.36)
    case .grey: LegacyColors.ksr_support_300.uiColor().mixDarker(0.36)
    }
  }

  public var disabledBackgroundColor: UIColor {
    switch self {
    case .blue: LegacyColors.ksr_trust_500.uiColor().mixLighter(0.36)
    case .grey: LegacyColors.ksr_support_300.uiColor().mixLighter(0.12)
    }
  }

  public var titleColor: UIColor {
    switch self {
    case .blue: LegacyColors.ksr_white.uiColor()
    case .grey: LegacyColors.ksr_support_700.uiColor()
    }
  }

  public var highlightedTitleColor: UIColor {
    switch self {
    case .blue: LegacyColors.ksr_white.uiColor()
    case .grey: LegacyColors.ksr_support_700.uiColor()
    }
  }

  public var disabledTitleColor: UIColor {
    switch self {
    case .blue: LegacyColors.ksr_white.uiColor()
    case .grey: LegacyColors.ksr_support_400.uiColor()
    }
  }

  public var font: UIFont {
    .ksr_ButtonLabel()
  }

  public var borderWidth: CGFloat {
    0.0
  }

  public var borderColor: UIColor {
    .clear
  }

  public var highlightedBorderColor: UIColor {
    self.borderColor
  }

  public var disabledBorderColor: UIColor {
    self.borderColor
  }

  public var cornerRadius: CGFloat {
    Styles.cornerRadius
  }

  public var buttonConfiguration: UIButton.Configuration {
    .filled()
  }

  public var loadingIndicatorColor: UIColor {
    self.highlightedBackgroundColor
  }
}
