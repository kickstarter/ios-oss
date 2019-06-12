import Foundation
@testable import Library
import ReactiveSwift
import UserNotifications

public struct MockPushRegistration: PushRegistrationType {
  static var registerProducer: SignalProducer<Bool, Never> = .empty
  static var hasAuthorizedNotificationsProducer: SignalProducer<Bool, Never> = .empty

  public static func register(for _: UNAuthorizationOptions) -> SignalProducer<Bool, Never> {
    return self.registerProducer
  }

  public static func hasAuthorizedNotifications() -> SignalProducer<Bool, Never> {
    return self.hasAuthorizedNotificationsProducer
  }
}
