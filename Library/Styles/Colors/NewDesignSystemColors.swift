import UIKit

public struct Colors {
  /// Background colors, mapped to `background/` namespace in Assets.
  public enum Background: String, AdaptiveColors {
    case accentGreenBold
    case accentGreenBoldPressed
    case accentGreenDisabled
    case accentGraySubtle
    case accentRedSubtle
    case action
    case actionDisabled
    case actionPressed
    case dangerBold
    case dangerBoldPressed
    case dangerDisabled
    case facebookDefault
    case inverseDisabled
    case inversePressed
    case surfacePrimary
    case selected
  }

  /// Border colors, mapped to `border/` namespace in Assets.
  public enum Border: String, AdaptiveColors {
    case active
    case bold
    case dangerBold
    case subtle
  }

  public enum Icon: String, AdaptiveColors {
    case green
    case primary
  }

  /// Text colors, mapped to `text/` namespace in Assets.
  public enum Text: String, AdaptiveColors {
    case accentRed
    case accentRedBolder
    case accentRedDisabled
    case accentRedInverseDisabled
    case disabled
    case inverseDisabled
    case inverseprimary
    case primary
  }
}
