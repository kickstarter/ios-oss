import enum UIKit.UIPressPhase

public extension UIPressPhase {
  public var isStartingPhase: Bool {
    return self == .began
  }

  public var isTerminatingPhase: Bool {
    return self == .cancelled || self == .ended
  }
}
