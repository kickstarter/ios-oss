import UIKit

struct Colors {
  /// Background colors, mapped to `background/` namespace in Assets.
  enum Background: String, AdaptativeColors {
    case accentGreenBold
    case accentGreenBoldPressed
    case accentGreenDisabled
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
  }

  /// Border colors, mapped to `border/` namespace in Assets.
  enum Border: String, AdaptativeColors {
    case bold
    case dangerBold
    case subtle
  }

  /// Text colors, mapped to `text/` namespace in Assets.
  enum Text: String, AdaptativeColors {
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
