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
    case .filled: Colors.Background.action.uiColor()
    case .green: Colors.Background.Accent.Green.bold.uiColor()
    case .filledInverted: Colors.Background.Surface.primary.uiColor()
    case .filledDestructive: Colors.Background.Danger.bold.uiColor()
    case .facebook:
      UIColor.hex(0x1877F2)
    default: .clear
    }
  }

  public var highlightedBackgroundColor: UIColor {
    switch self {
    case .filled: Colors.Background.Action.pressed.uiColor()
    case .green: Colors.Background.Accent.Green.Bold.pressed.uiColor()
    case .filledDestructive: Colors.Background.Danger.Bold.pressed.uiColor()
    case .borderlessDestructive, .outlinedDestructive: Colors.Background.Accent.Red.subtle.uiColor()
    case .facebook: self.backgroundColor.mixDarker(0.35)
    default: Colors.Background.Inverse.pressed.uiColor()
    }
  }

  public var disabledBackgroundColor: UIColor {
    switch self {
    case .filled: Colors.Background.Action.disabled.uiColor()
    case .green: Colors.Background.Accent.Green.disabled.uiColor()
    case .filledInverted: Colors.Background.Inverse.disabled.uiColor()
    case .filledDestructive: Colors.Background.Danger.disabled.uiColor()
    case .facebook: self.backgroundColor.mixLighter(0.35)
    default: .clear
    }
  }

  public var titleColor: UIColor {
    switch self {
    case .filled, .green, .facebook, .filledDestructive: Colors.Text.Inverse.primary.uiColor()
    case .filledInverted, .borderless, .outlined: Colors.Text.primary.uiColor()
    case .outlinedDestructive, .borderlessDestructive: Colors.Text.Accent.red.uiColor()
    }
  }

  public var highlightedTitleColor: UIColor {
    switch self {
    case .outlinedDestructive, .borderlessDestructive: Colors.Text.Accent.Red.bolder.uiColor()
    default: self.titleColor
    }
  }

  public var disabledTitleColor: UIColor {
    switch self {
    case .filled: Colors.Text.Inverse.disabled.uiColor()
    case .green, .filledInverted, .borderless, .outlined: Colors.Text.disabled.uiColor()
    case .filledDestructive: Colors.Text.Accent.Red.Inverse.disabled.uiColor()
    case .outlinedDestructive, .borderlessDestructive: Colors.Text.Accent.Red.disabled.uiColor()
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
    case .outlined: Colors.Border.bold.uiColor()
    case .outlinedDestructive: Colors.Background.Danger.bold.uiColor()
    default: .clear
    }
  }

  public var highlightedBorderColor: UIColor {
    switch self {
    case .outlinedDestructive: Colors.Border.Danger.bold.uiColor()
    default: self.borderColor
    }
  }

  public var disabledBorderColor: UIColor {
    switch self {
    case .outlined: Colors.Border.subtle.uiColor()
    case .outlinedDestructive: Colors.Border.Danger.subtle.uiColor()
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
