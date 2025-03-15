import UIKit

public enum KSRButtonStyle: KSRButtonStyleConfiguration, CaseIterable {
  case filled
  case green
  case filledInverted
  case filledDestructive
  case borderless
  case outlined
  case outlinedDestructive
  case borderlessDestructive
  case facebook

  public var backgroundColor: UIColor {
    switch self {
    case .filled: Colors.Background.action.adaptive()
    case .green: Colors.Background.accentGreenBold.adaptive()
    case .filledInverted: Colors.Background.surfacePrimary.adaptive()
    case .filledDestructive: Colors.Background.dangerBold.adaptive()
    case .facebook: Colors.Background.facebookDefault.adaptive()
    default: .clear
    }
  }

  public var highlightedBackgroundColor: UIColor {
    switch self {
    case .filled: Colors.Background.actionPressed.adaptive()
    case .green: Colors.Background.accentGreenBoldPressed.adaptive()
    case .filledDestructive: Colors.Background.dangerBoldPressed.adaptive()
    case .borderlessDestructive, .outlinedDestructive: Colors.Background.accentRedSubtle.adaptive()
    case .facebook: self.backgroundColor.mixDarker(0.35)
    default: Colors.Background.inversePressed.adaptive()
    }
  }

  public var disabledBackgroundColor: UIColor {
    switch self {
    case .filled: Colors.Background.actionDisabled.adaptive()
    case .green: Colors.Background.accentGreenDisabled.adaptive()
    case .filledInverted: Colors.Background.inverseDisabled.adaptive()
    case .filledDestructive: Colors.Background.dangerDisabled.adaptive()
    case .facebook: self.backgroundColor.mixLighter(0.35)
    default: .clear
    }
  }

  public var titleColor: UIColor {
    switch self {
    case .filled, .green, .facebook, .filledDestructive: Colors.Text.inverseprimary.adaptive()
    case .filledInverted, .borderless, .outlined: Colors.Text.primary.adaptive()
    case .outlinedDestructive, .borderlessDestructive: Colors.Text.accentRed.adaptive()
    }
  }

  public var highlightedTitleColor: UIColor {
    switch self {
    case .outlinedDestructive, .borderlessDestructive: Colors.Text.accentRedBolder.adaptive()
    default: self.titleColor
    }
  }

  public var disabledTitleColor: UIColor {
    switch self {
    case .filled: Colors.Text.inverseDisabled.adaptive()
    case .green, .filledInverted, .borderless, .outlined: Colors.Text.disabled.adaptive()
    case .filledDestructive: Colors.Text.accentRedInverseDisabled.adaptive()
    case .outlinedDestructive, .borderlessDestructive: Colors.Text.accentRedDisabled.adaptive()
    case .facebook: self.titleColor.mixLighter(0.35)
    }
  }

  public var font: UIFont {
    .ksr_ButtonLabel()
  }

  public var borderWidth: CGFloat {
    switch self {
    case .outlined, .outlinedDestructive: 1.0
    default: 0.0
    }
  }

  public var borderColor: UIColor {
    switch self {
    case .outlined: Colors.Border.bold.adaptive()
    case .outlinedDestructive: Colors.Background.dangerBold.adaptive()
    default: .clear
    }
  }

  public var highlightedBorderColor: UIColor {
    switch self {
    case .outlinedDestructive: Colors.Border.dangerBold.adaptive()
    default: self.borderColor
    }
  }

  public var disabledBorderColor: UIColor {
    switch self {
    case .outlined: Colors.Border.subtle.adaptive()
    case .outlinedDestructive: Colors.Text.accentRedDisabled.adaptive()
    default: self.borderColor
    }
  }

  public var cornerRadius: CGFloat {
    Styles.cornerRadius
  }

  public var buttonConfiguration: UIButton.Configuration {
    switch self {
    case .filled, .green, .filledDestructive, .facebook: .filled()
    case .outlined, .outlinedDestructive: .bordered()
    case .filledInverted, .borderless, .borderlessDestructive: .borderless()
    }
  }

  public var loadingIndicatorColor: UIColor {
    switch self {
    case .filledInverted, .borderless, .outlined: self.titleColor
    default: self.highlightedBackgroundColor
    }
  }
}
