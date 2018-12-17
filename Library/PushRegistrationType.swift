import Foundation
import ReactiveSwift
import Result
import UIKit
import UserNotifications

public protocol PushRegistrationType {
  static func register(for options: UNAuthorizationOptions) -> SignalProducer<Bool, NoError>
  static func hasAuthorizedNotifications() -> SignalProducer<Bool, NoError>
}
