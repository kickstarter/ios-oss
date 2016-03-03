import enum UIKit.UIGestureRecognizerState

public extension UIGestureRecognizerState {
  public var isStartingState: Bool {
    return self == .Began
  }

  public var isTerminatingState: Bool {
    return self == .Cancelled || self == .Ended || self == .Failed
  }
}
