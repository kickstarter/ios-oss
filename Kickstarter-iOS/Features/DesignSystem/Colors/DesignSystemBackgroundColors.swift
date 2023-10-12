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
      return DesignSystemColors.white.rawValue
    case .backgroundSurfaceInverse:
      return DesignSystemColors.grey10.rawValue
    case .backgroundDisabled:
      return DesignSystemColors.grey4.rawValue
    case .backgroundInverse:
      return DesignSystemColors.white.rawValue
    case .backgroundInverseHover:
      return DesignSystemColors.grey2.rawValue
    case .backgroundInversePressed:
      return DesignSystemColors.grey3.rawValue
    case .backgroundSelected:
      return DesignSystemColors.grey9.rawValue
    case .backgroundAction:
      return DesignSystemColors.grey10.rawValue
    case .backgroundActionHover:
      return DesignSystemColors.black.rawValue
    case .backgroundActionDisabled:
      return DesignSystemColors.grey5.rawValue
    case .backgroundActionPressed:
      return DesignSystemColors.grey9.rawValue
    case .backgroundAccentGreenBold:
      return DesignSystemColors.green6.rawValue
    case .backgroundAccentGreenSubtle:
      return DesignSystemColors.green2.rawValue
    case .backgroundAccentBlueBold:
      return DesignSystemColors.blue6.rawValue
    case .backgroundAccentBlueSubtle:
      return DesignSystemColors.blue2.rawValue
    case .backgroundAccentPurpleSubtle:
      return DesignSystemColors.purple2.rawValue
    case .backgroundDangerBold:
      return DesignSystemColors.red6.rawValue
    case .backgroundDangerSubtle:
      return DesignSystemColors.red2.rawValue
    case .backgroundDangerBoldPressed:
      return DesignSystemColors.red8.rawValue
    case .backgroundDangerBoldHovered:
      return DesignSystemColors.red7.rawValue
    case .backgroundDangerSubtleHovered:
      return DesignSystemColors.red3.rawValue
    case .backgroundAccentGrayBold:
      return DesignSystemColors.grey6.rawValue
    case .backgroundAccentGraySubtle:
      return DesignSystemColors.grey2.rawValue
    case .backgroundWarningBold:
      return DesignSystemColors.yellow6.rawValue
    case .backgroundWarningSubtle:
      return DesignSystemColors.yellow2.rawValue
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
