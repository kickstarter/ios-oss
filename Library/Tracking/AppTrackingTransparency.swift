import AdSupport
import AppTrackingTransparency
import Foundation

public protocol AppTrackingTransparencyType {
  func authorizationStatus() -> ATTrackingAuthorizationStatus
  func advertisingIdentifier(_ status: ATTrackingAuthorizationStatus) -> String?
}

public struct AppTrackingTransparency: AppTrackingTransparencyType {
  public init() {}

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

  public func advertisingIdentifier(_ status: ATTrackingAuthorizationStatus) -> String? {
    guard status == .authorized else { return nil }

    return ASIdentifierManager.shared().advertisingIdentifier.uuidString
  }
}
