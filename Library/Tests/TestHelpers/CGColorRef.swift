import class UIKit.CGColorRef

extension CGColorRef: Equatable {}
public func == (lhs: CGColorRef, rhs: CGColorRef) -> Bool {
  return CGColorEqualToColor(lhs, rhs)
}
