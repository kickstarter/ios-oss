import class UIKit.UIView

public extension UIView {
  static var defaultReusableId: String {
    return self.description().componentsSeparatedByString(".").dropFirst().joinWithSeparator(".")
  }
}
