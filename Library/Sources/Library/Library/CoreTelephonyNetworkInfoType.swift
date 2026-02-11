import CoreTelephony
import Foundation

public protocol CoreTelephonyNetworkInfoType {
  var serviceCurrentRadioAccessTechnology: [String: String]? { get }
}

extension CTTelephonyNetworkInfo: CoreTelephonyNetworkInfoType {
  public static func current() -> CoreTelephonyNetworkInfoType {
    #if targetEnvironment(simulator)
      return MockCoreTelephonyNetworkInfo()
    #else
      return CTTelephonyNetworkInfo()
    #endif
  }
}
