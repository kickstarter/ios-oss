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

  public var authorizationStatusValue: AppTrackingAuthorization {
    get {
      self.authorizationStatusProperty.value
    }
    set {
      self.authorizationStatusProperty.value = newValue
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
  var authorizationStatus: SignalProducer<AppTrackingAuthorization, Never> {
    self.authorizationStatusProperty.producer
      .replayLazily(upTo: 1)
      .skipRepeats()
  }
}
