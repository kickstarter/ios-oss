import Foundation
import ReactiveSwift
import Result
import UIKit
import UserNotifications

public struct PushRegistration: PushRegistrationType {
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

  public static func currentAuthorization() -> SignalProducer<Bool, NoError> {
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
