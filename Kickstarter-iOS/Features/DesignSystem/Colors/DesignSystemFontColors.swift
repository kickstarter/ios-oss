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
      return DesignSystemCoreColors.grey10.rawValue
    case .textInversePrimary:
      return DesignSystemCoreColors.white.rawValue
    case .textSecondary:
      return DesignSystemCoreColors.grey7.rawValue
    case .textInverseSecondary:
      return DesignSystemCoreColors.grey3.rawValue
    case .textDisabled:
      return DesignSystemCoreColors.grey5.rawValue
    case .textAccentGrey:
      return DesignSystemCoreColors.grey10.rawValue
    case .textAccentRed:
      return DesignSystemCoreColors.red6.rawValue
    case .textAccentRedBold:
      return DesignSystemCoreColors.red8.rawValue
    case .textAccentGreen:
      return DesignSystemCoreColors.green6.rawValue
    case .textAccentGreenBold:
      return DesignSystemCoreColors.green8.rawValue
    case .textAccentBlue:
      return DesignSystemCoreColors.blue6.rawValue
    case .textAccentBlueBold:
      return DesignSystemCoreColors.blue8.rawValue
    case .textAccentPurple:
      return DesignSystemCoreColors.purple6.rawValue
    case .textAccentPurpleBold:
      return DesignSystemCoreColors.purple8.rawValue
    case .textAccentYellow:
      return DesignSystemCoreColors.yellow6.rawValue
    case .textAccentYellowBold:
      return DesignSystemCoreColors.yellow8.rawValue
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
