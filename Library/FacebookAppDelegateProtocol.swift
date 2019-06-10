import FBSDKCoreKit
import Foundation
import UIKit

public protocol FacebookAppDelegateProtocol {
  func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any?
  ) -> Bool

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool
}

extension ApplicationDelegate: FacebookAppDelegateProtocol {}

internal final class MockFacebookAppDelegate: FacebookAppDelegateProtocol {
  internal var didFinishLaunching = false
  internal var openedUrl = false
  internal let didFinishLaunchingReturnValue: Bool
  internal let openURLReturnValue: Bool

  internal init(didFinishLaunchingReturnValue: Bool = true, openURLReturnValue: Bool = false) {
    self.didFinishLaunchingReturnValue = didFinishLaunchingReturnValue
    self.openURLReturnValue = openURLReturnValue
  }

  internal func application(
    _: UIApplication,
    open _: URL,
    sourceApplication _: String?,
    annotation _: Any?
  ) -> Bool {
    self.didFinishLaunching = true
    return self.didFinishLaunchingReturnValue
  }

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    self.openedUrl = true
    return self.openURLReturnValue
  }
}
