import UIKit

public extension UIPress.Phase {
  public var isStartingPhase: Bool {
    return self == .began
  }

  public var isTerminatingPhase: Bool {
    return self == .cancelled || self == .ended
  }
}
