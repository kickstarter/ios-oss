import AdSupport
import AppTrackingTransparency
import Foundation

public protocol AppTrackingTransparencyType {
  var advertisingIdentifier: String? { get }
  func updateAdvertisingIdentifier()
  func requestAndSetAuthorizationStatus()
  func shouldRequestAuthorizationStatus() -> Bool
}

public class AppTrackingTransparency: AppTrackingTransparencyType {
  public private(set) var advertisingIdentifier: String?

  public init() {
    self.updateAdvertisingIdentifier()
  }

  public func requestAndSetAuthorizationStatus() {
    ATTrackingManager.requestTrackingAuthorization { [weak self] authStatus in
      switch authStatus {
      case .authorized:
        self?.advertisingIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
      default:
        self?.advertisingIdentifier = nil
      }
    }
  }

  public func shouldRequestAuthorizationStatus() -> Bool {
    ATTrackingManager.trackingAuthorizationStatus == .notDetermined
  }

  public func updateAdvertisingIdentifier() {
    switch ATTrackingManager.trackingAuthorizationStatus {
    case .authorized:
      self.advertisingIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    default:
      self.advertisingIdentifier = nil
    }
  }
}
