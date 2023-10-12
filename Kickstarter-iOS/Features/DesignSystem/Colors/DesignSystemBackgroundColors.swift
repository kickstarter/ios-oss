import UIKit

public enum DesignSystemBackgroundColors {
  case backgroundSurfacePrimary
  case backgroundSurfaceInverse
  case backgroundDisabled
  case backgroundInverse
  case backgroundInverseHover
  case backgroundInversePressed
  case backgroundSelected
  case backgroundAction
  case backgroundActionHover
  case backgroundActionDisabled
  case backgroundActionPressed
  case backgroundAccentGreenBold
  case backgroundAccentGreenSubtle
  case backgroundAccentBlueBold
  case backgroundAccentBlueSubtle
  case backgroundAccentPurpleSubtle
  case backgroundDangerBold
  case backgroundDangerSubtle
  case backgroundDangerBoldPressed
  case backgroundDangerBoldHovered
  case backgroundDangerSubtleHovered
  case backgroundAccentGrayBold
  case backgroundAccentGraySubtle
  case backgroundWarningBold
  case backgroundWarningSubtle

  var rawValue: String {
    switch self {
    case .backgroundSurfacePrimary:
      return DesignSystemCoreColors.white.rawValue
    case .backgroundSurfaceInverse:
      return DesignSystemCoreColors.grey10.rawValue
    case .backgroundDisabled:
      return DesignSystemCoreColors.grey4.rawValue
    case .backgroundInverse:
      return DesignSystemCoreColors.white.rawValue
    case .backgroundInverseHover:
      return DesignSystemCoreColors.grey2.rawValue
    case .backgroundInversePressed:
      return DesignSystemCoreColors.grey3.rawValue
    case .backgroundSelected:
      return DesignSystemCoreColors.grey9.rawValue
    case .backgroundAction:
      return DesignSystemCoreColors.grey10.rawValue
    case .backgroundActionHover:
      return DesignSystemCoreColors.black.rawValue
    case .backgroundActionDisabled:
      return DesignSystemCoreColors.grey5.rawValue
    case .backgroundActionPressed:
      return DesignSystemCoreColors.grey9.rawValue
    case .backgroundAccentGreenBold:
      return DesignSystemCoreColors.green6.rawValue
    case .backgroundAccentGreenSubtle:
      return DesignSystemCoreColors.green2.rawValue
    case .backgroundAccentBlueBold:
      return DesignSystemCoreColors.blue6.rawValue
    case .backgroundAccentBlueSubtle:
      return DesignSystemCoreColors.blue2.rawValue
    case .backgroundAccentPurpleSubtle:
      return DesignSystemCoreColors.purple2.rawValue
    case .backgroundDangerBold:
      return DesignSystemCoreColors.red6.rawValue
    case .backgroundDangerSubtle:
      return DesignSystemCoreColors.red2.rawValue
    case .backgroundDangerBoldPressed:
      return DesignSystemCoreColors.red8.rawValue
    case .backgroundDangerBoldHovered:
      return DesignSystemCoreColors.red7.rawValue
    case .backgroundDangerSubtleHovered:
      return DesignSystemCoreColors.red3.rawValue
    case .backgroundAccentGrayBold:
      return DesignSystemCoreColors.grey6.rawValue
    case .backgroundAccentGraySubtle:
      return DesignSystemCoreColors.grey2.rawValue
    case .backgroundWarningBold:
      return DesignSystemCoreColors.yellow6.rawValue
    case .backgroundWarningSubtle:
      return DesignSystemCoreColors.yellow2.rawValue
    }
  }
}

extension DesignSystemBackgroundColors {
  public func load(_ colorSet: DesignSystemColorSet) -> UIColor {
    UIColor(named: "\(colorSet.rawValue)/\(self.rawValue)") ?? .white
  }
}

public func adaptiveBackgroundColor(_ colorSet: DesignSystemColorSet,
                                    _ style: DesignSystemBackgroundColors) -> UIColor {
  style.load(colorSet)
}
