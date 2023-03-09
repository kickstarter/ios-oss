import AdSupport
import AppTrackingTransparency
import Foundation

public protocol AppTrackingTransparencyType {
  func authorizationStatus() -> ATTrackingAuthorizationStatus
  func advertisingIdentifier() -> String?
}

public struct AppTrackingTransparency: AppTrackingTransparencyType {
  public func authorizationStatus() -> ATTrackingAuthorizationStatus {
    var authorizationStatus: ATTrackingAuthorizationStatus = .notDetermined

    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
      switch status {
      case .notDetermined:
        authorizationStatus = .notDetermined
      case .authorized:
        authorizationStatus = .authorized
      case .denied:
        authorizationStatus = .denied
      case .restricted:
        authorizationStatus = .restricted
      @unknown default:
        authorizationStatus = .notDetermined
      }
    })

    return authorizationStatus
  }

  public func advertisingIdentifier() -> String? {
    guard self.authorizationStatus() == .authorized else { return nil }

    return ASIdentifierManager.shared().advertisingIdentifier.uuidString
  }
}
