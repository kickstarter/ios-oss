import UIKit
import Foundation

public extension UIViewController {
  static var defaultNib: String {
    return self.description().componentsSeparatedByString(".").dropFirst().joinWithSeparator(".")
  }
}
