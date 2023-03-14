import Library

struct MockAppTrackingTransparency: AppTrackingTransparencyType {
  public var authStatusStub: ATTrackingAuthorizationStatus =
    .authorized // defaulting to .authorized so existing tests will still pass

  func authorizationStatus() -> ATTrackingAuthorizationStatus {
    return self.authStatusStub
  }

  func advertisingIdentifier(_ status: ATTrackingAuthorizationStatus) -> String? {
    guard status == .authorized else { return nil }

    return "advertisingIdentifier"
  }
}
