import Foundation
import ReactiveSwift
import Result
import UIKit
import UserNotifications

public enum PushNotificationType: CaseIterable {
  case alert
  case badge
  case sound

  public var userNotificationType: UIUserNotificationType {
    switch self {
    case .alert: return .alert
    case .badge: return .badge
    case .sound: return .sound
    }
  }

  @available(iOS 10.0, *)
  public var authorizationOption: UNAuthorizationOptions {
    switch self {
    case .alert: return .alert
    case .badge: return .badge
    case .sound: return .sound
    }
  }
}

extension Sequence where Element == PushNotificationType {
  func userNotificationTypes() -> UIUserNotificationType {
    var options: UIUserNotificationType = []

    self.forEach { options.insert($0.userNotificationType) }

    return options
  }

  @available(iOS 10.0, *)
  func authorizationOptions() -> UNAuthorizationOptions {
    var options: UNAuthorizationOptions = []

    self.forEach { options.insert($0.authorizationOption) }

    return options
  }
}

public protocol PushRegistrationType {
  static func register(for types: [PushNotificationType]) -> SignalProducer<Bool?, NoError>
  static func hasAuthorizedNotifications() -> SignalProducer<Bool, NoError>
}
