import UIKit

public extension UIPress.Phase {
  var isStartingPhase: Bool {
    return self == .began
  }

  var isTerminatingPhase: Bool {
    return self == .cancelled || self == .ended
  }
}
