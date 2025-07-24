import UIKit

extension UIUserInterfaceStyle {
  public var description: String {
    switch self {
    case .dark:
      return "dark"
    case .light:
      return "light"
    case .unspecified:
      return "unspecified"
    @unknown default:
      assertionFailure("Unhandled UIUserInterfaceStyle case encountered.")
      return "unknown"
    }
  }
}
