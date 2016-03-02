import UIKit

public extension UIPressPhase {
  public var isStartingPhase: Bool {
    return self == .Began
  }

  public var isTerminatingPhase: Bool {
    return self == .Cancelled || self == .Ended
  }
}
