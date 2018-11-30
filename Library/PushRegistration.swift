import Foundation
import ReactiveSwift
import Result
import UIKit
import UserNotifications

public struct PushRegistration: PushRegistrationType {

  /**
   Returns a signal producer that emits an option `Bool` value representing whether or not the user
   granted the requested push notification permissions. This value is not returned on iOS versions < 10.0.
   The returned producer emits once and completes.

   - parameter for: The types to register that we will request permissions for.

   - returns: A signal producer.
   */
  public static func register(for types: [PushNotificationType]) -> SignalProducer<Bool?, NoError> {
    func performRegistration() {
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }

    guard #available(iOS 10.0, *) else {
      UIApplication.shared.registerUserNotificationSettings(
        UIUserNotificationSettings(types: types.userNotificationTypes(), categories: [])
      )

      performRegistration()

      return .init(value: nil)
    }

    return SignalProducer { observer, _ in
      UNUserNotificationCenter.current()
        .requestAuthorization(options: types.authorizationOptions(), completionHandler: { isGranted, _ in
          if isGranted {
            performRegistration()
          }

          observer.send(value: isGranted)
          observer.sendCompleted()
        })
    }
  }

  /**
   Returns a signal producer that emits a `Bool` value representing whether the user has allowed push
   notification permissions in the past.
   The returned producer emits once and completes.

   - returns: A signal producer.
   */
  public static func hasAuthorizedNotifications() -> SignalProducer<Bool, NoError> {
      guard #available(iOS 10.0, *) else {
        return .init(value: UIApplication.shared.isRegisteredForRemoteNotifications)
      }

      return SignalProducer { observer, _ in
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          observer.send(value: settings.authorizationStatus == .authorized)
          observer.sendCompleted()
        }
      }
  }
}
