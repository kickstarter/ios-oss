import Library
import ReactiveSwift

class MockAppTrackingTransparency: AppTrackingTransparencyType {
  public private(set) var advertisingIdentifier: String?
  public var requestAndSetAuthorizationStatusFlag = false

  public var shouldRequestAuthStatus: Bool {
    get {
      self.authorizationStatusProperty.value == .notDetermined
    }
    set {
      self.authorizationStatusProperty.value = (newValue ? .notDetermined : .authorized)
    }
  }

  func updateAdvertisingIdentifier() {
    self.advertisingIdentifier = self.shouldRequestAuthStatus ? "advertisingIdentifer" : nil
  }

  func requestAndSetAuthorizationStatus() {
    self.authorizationStatusProperty.value = .authorized
    self.advertisingIdentifier = self.requestAndSetAuthorizationStatusFlag ? "advertisingIdentifier" : nil
  }

  func shouldRequestAuthorizationStatus() -> Bool {
    self.shouldRequestAuthStatus
  }

  private var authorizationStatusProperty = MutableProperty<AppTrackingAuthorization>(.notDetermined)
  var authorizationStatus: Signal<AppTrackingAuthorization, Never> {
    self.authorizationStatusProperty.signal
  }
}
