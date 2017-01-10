import UIKit

/**
 *  A type that behaves like a UIDevice.
 */
public protocol UIDeviceType {
  var modelCode: String { get }
  var systemName: String { get }
  var systemVersion: String { get }
  var userInterfaceIdiom: UIUserInterfaceIdiom { get }
}

extension UIDevice: UIDeviceType {
  public var modelCode: String {
    var size: Int = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](repeating: 0, count: Int(size))
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String(cString: machine)
  }
}

internal struct MockDevice: UIDeviceType {
  internal let modelCode = "MockmodelCode"
  internal let systemName = "MockSystemName"
  internal let systemVersion: String = "MockSystemVersion"
  internal let userInterfaceIdiom: UIUserInterfaceIdiom

  internal init (userInterfaceIdiom: UIUserInterfaceIdiom) {
    self.userInterfaceIdiom = userInterfaceIdiom
  }
}
