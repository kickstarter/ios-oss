import class UIKit.CGColorRef
import func UIKit.CGColorEqualToColor

extension CGColor: Equatable {}
public func == (lhs: CGColor, rhs: CGColor) -> Bool {
  return CGColorEqualToColor(lhs, rhs)
}
