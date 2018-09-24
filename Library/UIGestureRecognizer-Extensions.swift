import UIKit

public extension UIGestureRecognizer.State {
  public var isStartingState: Bool {
    return self == .began
  }

  public var isTerminatingState: Bool {
    return self == .cancelled || self == .ended || self == .failed
  }
}
