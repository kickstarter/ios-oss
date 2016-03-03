import class UIKit.UIViewController

public extension UIViewController {
  static var defaultNib: String {
    return self.description().componentsSeparatedByString(".").dropFirst().joinWithSeparator(".")
  }
}
