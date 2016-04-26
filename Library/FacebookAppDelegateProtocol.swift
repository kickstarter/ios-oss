import UIKit
import Foundation
import FBSDKCoreKit

public protocol FacebookAppDelegateProtocol {
  func application(application: UIApplication!,
                   didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]!) -> Bool
  func application(application: UIApplication!,
                   openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool
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

  internal func application(application: UIApplication!,
                            didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]!) -> Bool {
    self.didFinishLaunching = true
    return self.didFinishLaunchingReturnValue
  }

  internal func application(application: UIApplication!,
                            openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool {
    self.openedUrl = true
    return self.openURLReturnValue
  }
}
