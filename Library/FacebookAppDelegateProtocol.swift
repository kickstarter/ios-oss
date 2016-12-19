import UIKit
import Foundation
import FBSDKCoreKit

public protocol FacebookAppDelegateProtocol {
  func application(_ application: UIApplication!,
                   didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]!) -> Bool
  func application(_ application: UIApplication!,
                   openURL url: URL!, sourceApplication: String!, annotation: AnyObject!) -> Bool
}

extension FBSDKApplicationDelegate: FacebookAppDelegateProtocol {
}

internal final class MockFacebookAppDelegate: FacebookAppDelegateProtocol {
  internal var didFinishLaunching = false
  internal var openedUrl = false
  internal let didFinishLaunchingReturnValue: Bool
  internal let openURLReturnValue: Bool

  internal init(didFinishLaunchingReturnValue: Bool = true, openURLReturnValue: Bool = false) {
    self.didFinishLaunchingReturnValue = didFinishLaunchingReturnValue
    self.openURLReturnValue = openURLReturnValue
  }

  internal func application(_ application: UIApplication!,
                            didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]!) -> Bool {
    self.didFinishLaunching = true
    return self.didFinishLaunchingReturnValue
  }

  internal func application(_ application: UIApplication!,
                            openURL url: URL!, sourceApplication: String!, annotation: AnyObject!) -> Bool {
    self.openedUrl = true
    return self.openURLReturnValue
  }
}
