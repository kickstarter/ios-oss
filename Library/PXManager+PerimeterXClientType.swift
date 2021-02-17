import Foundation
import PerimeterX

public extension PXManager {
  /**
   Returns a `PXManager` instance, for PerimeterX.
   */
  static func configuredClient() -> PXManager {
    if let pxManager = PXManager.sharedInstance() {
      return pxManager
    }
    return PXManager.init()
  }
}

public protocol PerimeterXClientType: AnyObject {}
