import UIKit

/**
 *  A type that behaves like a UIDevice.
 */
public protocol UIDeviceType {
  var systemName: String { get }
  var systemVersion: String { get }
  var userInterfaceIdiom: UIUserInterfaceIdiom { get }
}

extension UIDevice: UIDeviceType {
}

internal struct MockDevice: UIDeviceType {
  internal let systemName = "MockSystemName"
  internal let systemVersion: String = "MockSystemVersion"
  internal let userInterfaceIdiom: UIUserInterfaceIdiom

  internal init (userInterfaceIdiom: UIUserInterfaceIdiom) {
    self.userInterfaceIdiom = userInterfaceIdiom
  }
}
