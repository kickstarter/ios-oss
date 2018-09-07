import Foundation

public enum SettingsSwitchCellType {
  case privacy

  public var titleString: String {
    switch self {
    case .privacy:
      return Strings.Private_profile()
    }
  }

  public var primaryDescriptionString: String {
    switch self {
      case .privacy:
        return Strings.If_your_profile_is_private()
    }
  }

  public var secondaryDescriptionString: String {
    switch self {
    case .privacy:
      return Strings.If_your_profile_is_public()
    }
  }
}
