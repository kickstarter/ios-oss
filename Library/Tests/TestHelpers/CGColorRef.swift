import class UIKit.CGColorRef
import func UIKit.CGColorEqualToColor

extension CGColorRef: Equatable {}
public func == (lhs: CGColorRef, rhs: CGColorRef) -> Bool {
  return CGColorEqualToColor(lhs, rhs)
}
