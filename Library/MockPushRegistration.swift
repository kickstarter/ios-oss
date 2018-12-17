import Foundation
@testable import Library
import ReactiveSwift
import Result
import UserNotifications

public struct MockPushRegistration: PushRegistrationType {
  static var registerProducer: SignalProducer<Bool, NoError> = .empty
  static var hasAuthorizedNotificationsProducer: SignalProducer<Bool, NoError> = .empty

  public static func register(for options: UNAuthorizationOptions) -> SignalProducer<Bool, NoError> {
    return self.registerProducer
  }

  public static func hasAuthorizedNotifications() -> SignalProducer<Bool, NoError> {
    return self.hasAuthorizedNotificationsProducer
  }
}
