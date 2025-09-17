import Foundation
import Library
import UIKit

/// Mock implementation of FacebookSDKType for testing
public struct MockFacebookSDK: FacebookSDKType {
  public static var configureCalled = false
  public static var configureAppID: String?
  public static var configureApplication: UIApplication?
  public static var configureLaunchOptions: [UIApplication.LaunchOptionsKey: Any]?

  public static var handleOpenURLCalled = false
  public static var handleOpenURLApp: UIApplication?
  public static var handleOpenURLURL: URL?
  public static var handleOpenURLOptions: [UIApplication.OpenURLOptionsKey: Any]?
  public static var handleOpenURLReturnValue = false

  public static func configure(
    appID: String?,
    application: UIApplication,
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) {
    self.configureCalled = true
    self.configureAppID = appID
    self.configureApplication = application
    self.configureLaunchOptions = launchOptions
  }

  public static func handleOpenURL(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool {
    self.handleOpenURLCalled = true
    self.handleOpenURLApp = app
    self.handleOpenURLURL = url
    self.handleOpenURLOptions = options
    return self.handleOpenURLReturnValue
  }

  /// Reset all mock state for testing
  public static func reset() {
    self.configureCalled = false
    self.configureAppID = nil
    self.configureApplication = nil
    self.configureLaunchOptions = nil

    self.handleOpenURLCalled = false
    self.handleOpenURLApp = nil
    self.handleOpenURLURL = nil
    self.handleOpenURLOptions = nil
    self.handleOpenURLReturnValue = false
  }
}
