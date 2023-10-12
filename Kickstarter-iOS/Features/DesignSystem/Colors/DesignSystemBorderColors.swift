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
      return DesignSystemColors.blue8.rawValue
    case .borderAccentBlueSubtle:
      return DesignSystemColors.blue4.rawValue
    case .borderAccentGreenSubtle:
      return DesignSystemColors.green4.rawValue
    case .borderWarningBold:
      return DesignSystemColors.yellow8.rawValue
    case .borderWarningSubtle:
      return DesignSystemColors.yellow4.rawValue
    case .borderDisabled:
      return DesignSystemColors.grey2.rawValue
    case .borderBoldHover:
      return DesignSystemColors.grey8.rawValue
    case .borderSubtleHover:
      return DesignSystemColors.grey5.rawValue
    case .borderActive:
      return DesignSystemColors.grey8.rawValue
    case .borderBold:
      return DesignSystemColors.grey4.rawValue
    case .borderDangerBold:
      return DesignSystemColors.red8.rawValue
    case .borderDangerSubtle:
      return DesignSystemColors.red4.rawValue
    case .borderSubtle:
      return DesignSystemColors.grey3.rawValue
    case .borderFocus:
      return DesignSystemColors.blue5.rawValue
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
