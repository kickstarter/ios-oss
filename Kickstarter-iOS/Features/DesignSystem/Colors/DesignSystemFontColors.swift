import UIKit

public enum DesignSystemFontColors {
  case textPrimary
  case textInversePrimary
  case textSecondary
  case textInverseSecondary
  case textDisabled
  case textAccentGrey
  case textAccentRed
  case textAccentRedBold
  case textAccentGreen
  case textAccentGreenBold
  case textAccentBlue
  case textAccentBlueBold
  case textAccentPurple
  case textAccentPurpleBold
  case textAccentYellow
  case textAccentYellowBold

  var rawValue: String {
    switch self {
    case .textPrimary:
      return DesignSystemColors.grey10.rawValue
    case .textInversePrimary:
      return DesignSystemColors.white.rawValue
    case .textSecondary:
      return DesignSystemColors.grey7.rawValue
    case .textInverseSecondary:
      return DesignSystemColors.grey3.rawValue
    case .textDisabled:
      return DesignSystemColors.grey5.rawValue
    case .textAccentGrey:
      return DesignSystemColors.grey10.rawValue
    case .textAccentRed:
      return DesignSystemColors.red6.rawValue
    case .textAccentRedBold:
      return DesignSystemColors.red8.rawValue
    case .textAccentGreen:
      return DesignSystemColors.green6.rawValue
    case .textAccentGreenBold:
      return DesignSystemColors.green8.rawValue
    case .textAccentBlue:
      return DesignSystemColors.blue6.rawValue
    case .textAccentBlueBold:
      return DesignSystemColors.blue8.rawValue
    case .textAccentPurple:
      return DesignSystemColors.purple6.rawValue
    case .textAccentPurpleBold:
      return DesignSystemColors.purple8.rawValue
    case .textAccentYellow:
      return DesignSystemColors.yellow6.rawValue
    case .textAccentYellowBold:
      return DesignSystemColors.yellow8.rawValue
    }
  }
}

extension DesignSystemFontColors {
  public func load(_ colorSet: DesignSystemColorSet) -> UIColor {
    UIColor(named: "\(colorSet.rawValue)/\(self.rawValue)") ?? .white
  }
}

public func adaptiveFontColor(_ colorSet: DesignSystemColorSet, _ style: DesignSystemFontColors) -> UIColor {
  style.load(colorSet)
}
