import Library

class MockAppTrackingTransparency: AppTrackingTransparencyType {
  public private(set) var advertisingIdentifier: String? = "advertisingIdentifier"
  public var shouldRequestAuthStatus = true

  func updateAdvertisingIdentifier() {
    self.advertisingIdentifier = self.shouldRequestAuthStatus ? "advertisingIdentifer" : nil
  }

  func requestAndSetAuthorizationStatus() {}

  func shouldRequestAuthorizationStatus() -> Bool {
    self.shouldRequestAuthStatus
  }
}
