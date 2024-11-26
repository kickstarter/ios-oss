import AdSupport
import AppTrackingTransparency
import Foundation
import ReactiveSwift

public typealias AppTrackingAuthorization = ATTrackingManager.AuthorizationStatus

public protocol AppTrackingTransparencyType {
  var advertisingIdentifier: String? { get }
  var authorizationStatus: SignalProducer<AppTrackingAuthorization, Never> { get }
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
      self?.authorizationStatusProperty.value = authStatus

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
    let status = ATTrackingManager.trackingAuthorizationStatus
    self.authorizationStatusProperty.value = status

    switch status {
    case .authorized:
      self.advertisingIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    default:
      self.advertisingIdentifier = nil
    }
  }

  public var authorizationStatus: SignalProducer<AppTrackingAuthorization, Never> {
    self.authorizationStatusProperty.producer
      .replayLazily(upTo: 1)
      .skipRepeats()
  }

  // MARK: Subjects

  private let authorizationStatusProperty = MutableProperty<AppTrackingAuthorization>(.notDetermined)
}
