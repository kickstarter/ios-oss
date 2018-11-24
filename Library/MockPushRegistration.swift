import Foundation
@testable import Library
import ReactiveSwift
import Result

public struct MockPushRegistration: PushRegistrationType {
  static var registerProducer: SignalProducer<Bool?, NoError> = .empty
  static var currentAuthorizationProducer: SignalProducer<Bool, NoError> = .empty

  public static func register(for types: [PushNotificationType]) -> SignalProducer<Bool?, NoError> {
    return self.registerProducer
  }

  public static func currentAuthorization() -> SignalProducer<Bool, NoError> {
    return self.currentAuthorizationProducer
  }
}
