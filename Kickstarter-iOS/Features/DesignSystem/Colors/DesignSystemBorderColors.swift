import UIKit

public enum DesignSystemBorderColors {
  case borderAccentBlueBold
  case borderAccentBlueSubtle
  case borderAccentGreenSubtle
  case borderWarningBold
  case borderWarningSubtle
  case borderDisabled
  case borderBoldHover
  case borderSubtleHover
  case borderActive
  case borderBold
  case borderDangerBold
  case borderDangerSubtle
  case borderSubtle
  case borderFocus

  var rawValue: String {
    switch self {
    case .borderAccentBlueBold:
      return DesignSystemCoreColors.blue8.rawValue
    case .borderAccentBlueSubtle:
      return DesignSystemCoreColors.blue4.rawValue
    case .borderAccentGreenSubtle:
      return DesignSystemCoreColors.green4.rawValue
    case .borderWarningBold:
      return DesignSystemCoreColors.yellow8.rawValue
    case .borderWarningSubtle:
      return DesignSystemCoreColors.yellow4.rawValue
    case .borderDisabled:
      return DesignSystemCoreColors.grey2.rawValue
    case .borderBoldHover:
      return DesignSystemCoreColors.grey8.rawValue
    case .borderSubtleHover:
      return DesignSystemCoreColors.grey5.rawValue
    case .borderActive:
      return DesignSystemCoreColors.grey8.rawValue
    case .borderBold:
      return DesignSystemCoreColors.grey4.rawValue
    case .borderDangerBold:
      return DesignSystemCoreColors.red8.rawValue
    case .borderDangerSubtle:
      return DesignSystemCoreColors.red4.rawValue
    case .borderSubtle:
      return DesignSystemCoreColors.grey3.rawValue
    case .borderFocus:
      return DesignSystemCoreColors.blue5.rawValue
    }
  }
}

extension DesignSystemBorderColors {
  public func load(_ colorSet: DesignSystemColorSet) -> UIColor {
    UIColor(named: "\(colorSet.rawValue)/\(self.rawValue)") ?? .white
  }
}

public func adaptiveBackgroundColor(_ colorSet: DesignSystemColorSet,
                                    _ style: DesignSystemBorderColors) -> UIColor {
  style.load(colorSet)
}
