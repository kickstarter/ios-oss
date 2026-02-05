import Foundation

internal struct MockCoreTelephonyNetworkInfo: CoreTelephonyNetworkInfoType {
  var current: [String: String]? = nil
  var serviceCurrentRadioAccessTechnology: [String: String]? {
    self.current
  }
}
