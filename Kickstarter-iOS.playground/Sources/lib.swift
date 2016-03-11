import UIKit

/**
 Compares two UIColor's using their white values.
 */
public func compareColorWhites(a: UIColor, _ b: UIColor) -> Bool {
  return a.white < b.white
}

extension UIColor {
  var white: CGFloat {
    var w: CGFloat = 0
    getWhite(&w, alpha: nil)
    return w
  }
}
