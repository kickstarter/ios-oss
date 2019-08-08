import UIKit

public enum MessageBannerType {
  case success
  case error
  case info

  var backgroundColor: UIColor {
    switch self {
    case .success:
      return .ksr_cobalt_500
    case .error:
      return .ksr_apricot_500
    case .info:
      return .ksr_cobalt_500
    }
  }

  var iconImageName: String? {
    switch self {
    case .success:
      return "icon--confirmation"
    case .error:
      return "icon--alert"
    default:
      return nil
    }
  }

  var iconImageTintColor: UIColor? {
    switch self {
    case .error:
      return .black
    default:
      return nil
    }
  }

  var textColor: UIColor {
    switch self {
    case .success, .info:
      return .white
    case .error:
      return .ksr_soft_black
    }
  }

  var textAlignment: NSTextAlignment {
    switch self {
    case .info:
      return .center
    default:
      return .left
    }
  }

  var shouldShowIconImage: Bool {
    switch self {
    case .info:
      return false
    default:
      return true
    }
  }
}
