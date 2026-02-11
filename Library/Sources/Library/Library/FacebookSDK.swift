import FacebookCore
import Foundation
import UIKit

/// Concrete implementation of FacebookSDKType using FacebookCore
public enum FacebookSDK: FacebookSDKType {
  public static func configure(
    appID: String?,
    application: UIApplication,
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) {
    FacebookCore.Settings.shared.isEventDataUsageLimited = true
    FacebookCore.Settings.shared.appID = appID
    FacebookCore.ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }

  public static func handleOpenURL(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool {
    return FacebookCore.ApplicationDelegate.shared.application(app, open: url, options: options)
  }
}
