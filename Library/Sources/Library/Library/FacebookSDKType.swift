import Foundation
import UIKit

/// Protocol defining Facebook SDK operations for login and URL handling
public protocol FacebookSDKType {
  /// Configure the Facebook SDK with app ID and launch options
  static func configure(
    appID: String?,
    application: UIApplication,
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  )

  /// Handle URL opening for Facebook SDK
  static func handleOpenURL(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool
}
