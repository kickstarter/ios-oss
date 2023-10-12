import UIKit

public enum DesignSystemIconColors {
  case icon
  case iconDanger
  case iconWarning
  case iconSubtle
  case iconInverse
  case iconInfo
  case iconDisabled

  var rawValue: String {
    switch self {
    case .icon:
      return DesignSystemCoreColors.grey8.rawValue
    case .iconDanger:
      return DesignSystemCoreColors.red7.rawValue
    case .iconWarning:
      return DesignSystemCoreColors.yellow7.rawValue
    case .iconSubtle:
      return DesignSystemCoreColors.grey6.rawValue
    case .iconInverse:
      return DesignSystemCoreColors.grey3.rawValue
    case .iconInfo:
      return DesignSystemCoreColors.blue7.rawValue
    case .iconDisabled:
      return DesignSystemCoreColors.grey5.rawValue
    }
  }
}

extension DesignSystemIconColors {
  public func load(_ colorSet: DesignSystemColorSet) -> UIColor {
    UIColor(named: "\(colorSet.rawValue)/\(self.rawValue)") ?? .white
  }
}

public func adaptiveFontColor(_ colorSet: DesignSystemColorSet, _ style: DesignSystemIconColors) -> UIColor {
  style.load(colorSet)
}
