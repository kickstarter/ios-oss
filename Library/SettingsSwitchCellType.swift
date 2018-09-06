import Foundation

public enum SettingsSwitchCellType {
  case privacy

  public var titleString: String {
    switch self {
    case .privacy:
      return Strings.Private_profile()
    }
  }

//  var descriptionString: String {
////    switch self {
////      case .privacy:
////
////    }
//  }
}
