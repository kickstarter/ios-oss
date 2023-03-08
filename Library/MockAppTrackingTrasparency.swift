import Library

struct MockAppTrackingTransparencyService: AppTrackingTransparencyType {
  public var authStatusStub: ATTrackingAuthorizationStatus =
    .authorized // defaulting to .authorized so existing tests will still pass

  func authorizationStatus() -> ATTrackingAuthorizationStatus {
    return self.authStatusStub
  }

  func advertisingIdentifier() -> String? {
    return "advertisingIdentifier"
  }
}
