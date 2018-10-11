import UIKit
import Library

public enum MessageBannerType {
  case success
  case error
  case info

  var backgroundColor: UIColor {
    switch self {
    case .success:
      return UIColor.ksr_cobalt_500
    case .error:
      return UIColor.ksr_apricot_600
    case .info:
      return UIColor.ksr_cobalt_500
    }
  }

  var iconImage: UIImage? {
    switch self {
    case .success:
      return image(named: "icon--confirmation",
                   inBundle: Bundle.framework,
                   compatibleWithTraitCollection: nil)
    case .error:
      return image(named: "icon--alert",
                   inBundle: Bundle.framework,
                   compatibleWithTraitCollection: nil)
    default:
      return nil
    }
  }

  var textColor: UIColor {
    switch self {
    case .success, .info:
      return .white
    case .error:
      return UIColor.ksr_text_dark_grey_900
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
