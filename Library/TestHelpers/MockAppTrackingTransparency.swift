import Library

class MockAppTrackingTransparency: AppTrackingTransparencyType {
  public private(set) var advertisingIdentifier: String?
  public var shouldRequestAuthStatus = true
  public var requestAndSetAuthorizationStatusFlag = false

  func updateAdvertisingIdentifier() {
    self.advertisingIdentifier = self.shouldRequestAuthStatus ? "advertisingIdentifer" : nil
  }

  func requestAndSetAuthorizationStatus() {
    self.advertisingIdentifier = self.requestAndSetAuthorizationStatusFlag ? "advertisingIdentifier" : nil
  }

  func shouldRequestAuthorizationStatus() -> Bool {
    self.shouldRequestAuthStatus
  }
}
