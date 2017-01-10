import UIKit

/**
 Compares two UIColor's using their white values.
 */
public func compareColorWhites(_ a: UIColor, _ b: UIColor) -> Bool {
  return a._white < b._white
}

extension UIColor {
  var _white: CGFloat {
    var w: CGFloat = 0
    self.getWhite(&w, alpha: nil)
    return w
  }
}
