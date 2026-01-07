import Foundation

internal struct MockCoreTelephonyNetworkInfo: CoreTelephonyNetworkInfoType {
  var current: [String: String]? = ["service": "wifi"]
  var serviceCurrentRadioAccessTechnology: [String: String]? {
    self.current
  }
}
