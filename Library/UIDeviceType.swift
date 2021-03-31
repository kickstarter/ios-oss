import UIKit

/**
 *  A type that behaves like a UIDevice.
 */
public protocol UIDeviceType {
  var identifierForVendor: UUID? { get }
  var modelCode: String { get }
  var orientation: UIDeviceOrientation { get }
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
  internal var identifierForVendor = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
  internal var modelCode = "MockmodelCode"
  internal var orientation: UIDeviceOrientation
  internal var systemVersion: String = "MockSystemVersion"
  internal var userInterfaceIdiom: UIUserInterfaceIdiom

  internal init(
    userInterfaceIdiom: UIUserInterfaceIdiom = .phone,
    orientation: UIDeviceOrientation = .portrait
  ) {
    self.userInterfaceIdiom = userInterfaceIdiom
    self.orientation = orientation
  }
}

extension UIDeviceType {
  var deviceType: String {
    switch self.userInterfaceIdiom {
    case .phone: return "phone"
    case .pad: return "tablet"
    case .tv: return "tv"
    default: return "unspecified"
    }
  }
}
