import Foundation
import ReactiveSwift
import UIKit
import UserNotifications

public struct PushRegistration: PushRegistrationType {
  /**
   Registers to receive the APNs token on app launch. This is to avoid the possibltiy of tokens
   being replaced if one of the following happens:
     - restoring the phone from a backup
     - transferring data from one phone to another
     - not having reinstalled the app or logged out for an extended period of time
   */
  public static func registerForPushTokenOnAppLaunch() {
    UIApplication.shared.registerForRemoteNotifications()
  }

  /**
   Returns a signal producer that emits an option `Bool` value representing whether or not the user
   granted the requested push notification permissions. This value is not returned on iOS versions < 10.0.
   The returned producer emits once and completes.

   - parameter for: The types to register that we will request permissions for.

   - returns: A signal producer.
   */
  public static func register(for options: UNAuthorizationOptions) -> SignalProducer<Bool, Never> {
    return SignalProducer { observer, _ in
      UNUserNotificationCenter.current()
        .requestAuthorization(options: options, completionHandler: { isGranted, _ in
          if isGranted {
            DispatchQueue.main.async {
              UIApplication.shared.registerForRemoteNotifications()
            }
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
  public static func hasAuthorizedNotifications() -> SignalProducer<Bool, Never> {
    return SignalProducer { observer, _ in
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        observer.send(value: settings.authorizationStatus == .authorized)
        observer.sendCompleted()
      }
    }
  }
}
