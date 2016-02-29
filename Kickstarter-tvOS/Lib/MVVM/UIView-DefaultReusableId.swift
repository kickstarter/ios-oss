import UIKit
import Foundation

public extension UIView {
  static var defaultReusableId: String {
    return self.description().componentsSeparatedByString(".").dropFirst().joinWithSeparator(".")
  }
}
