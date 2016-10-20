import FBSDKCoreKit
import Foundation
import HockeySDK
import KsApi
import Kickstarter_Framework
import Library
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  private let viewModel: AppDelegateViewModelType = AppDelegateViewModel()

  internal var rootTabBarController: RootTabBarViewController? {
    return self.window?.rootViewController as? RootTabBarViewController
  }

  // swiftlint:disable function_body_length
  func application(application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    AppEnvironment.replaceCurrentEnvironment(
      AppEnvironment.fromStorage(
        ubiquitousStore: NSUbiquitousKeyValueStore.defaultStore(),
        userDefaults: NSUserDefaults.standardUserDefaults()
      )
    )

    // NB: We have to push this shared instance directly because somehow we get two different shared
    //     instances if we use the one from `Environment.init`.
    AppEnvironment.replaceCurrentEnvironment(facebookAppDelegate: FBSDKApplicationDelegate.sharedInstance())

    self.viewModel.outputs.updateCurrentUserInEnvironment
      .observeForUI()
      .observeNext { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        self?.viewModel.inputs.currentUserUpdatedInEnvironment()
    }

    self.viewModel.outputs.forceLogout
      .observeForUI()
      .observeNext {
        AppEnvironment.logout()
        NSNotificationCenter.defaultCenter().postNotification(
          NSNotification(name: CurrentUserNotifications.sessionEnded, object: nil)
        )
    }

    self.viewModel.outputs.updateConfigInEnvironment
      .observeForUI()
      .observeNext { AppEnvironment.updateConfig($0) }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)

    self.viewModel.outputs.presentViewController
      .observeForUI()
      .observeNext { [weak self] in
        self?.rootTabBarController?.dismissViewControllerAnimated(true, completion: nil)
        self?.rootTabBarController?.presentViewController($0, animated: true, completion: nil)
    }

    self.viewModel.outputs.goToDiscovery
      .observeForUI()
      .observeNext { [weak self] in self?.rootTabBarController?.switchToDiscovery(params: $0) }

    self.viewModel.outputs.goToActivity
      .observeForUI()
      .observeNext { [weak self] in self?.rootTabBarController?.switchToActivities() }

    self.viewModel.outputs.goToDashboard
      .observeForUI()
      .observeNext { [weak self] in self?.rootTabBarController?.switchToDashboard(project: $0) }

    self.viewModel.outputs.registerUserNotificationSettings
      .observeForUI()
      .observeNext {
        UIApplication.sharedApplication().registerUserNotificationSettings(
          UIUserNotificationSettings(forTypes: .Alert, categories: [])
        )
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    self.viewModel.outputs.unregisterForRemoteNotifications
      .observeForUI()
      .observeNext(UIApplication.sharedApplication().unregisterForRemoteNotifications)

    self.viewModel.outputs.presentRemoteNotificationAlert
      .observeForUI()
      .observeNext { [weak self] in self?.presentRemoteNotificationAlert($0) }

    self.viewModel.outputs.configureHockey
      .observeForUI()
      .observeNext { data in
        let manager = BITHockeyManager.sharedHockeyManager()
        manager.configureWithIdentifier(data.appIdentifier)
        manager.crashManager.crashManagerStatus = .AutoSend
        manager.disableUpdateManager = data.disableUpdates
        manager.userID = data.userId
        manager.userName = data.userName
        manager.startManager()
        manager.authenticator.authenticateInstallation()
    }

    self.viewModel.outputs.synchronizeUbiquitousStore
      .observeForUI()
      .observeNext {
        AppEnvironment.current.ubiquitousStore.synchronize()
    }

    NSNotificationCenter
      .defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    NSNotificationCenter
      .defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }

    self.window?.tintColor = .ksr_navy_700

    self.viewModel.inputs
      .applicationDidFinishLaunching(application: application, launchOptions: launchOptions)

    return true
  }
  // swiftlint:enable function_body_length

  func applicationWillEnterForeground(application: UIApplication) {
    self.viewModel.inputs.applicationWillEnterForeground()
  }

  func applicationDidEnterBackground(application: UIApplication) {
    self.viewModel.inputs.applicationDidEnterBackground()
  }

  func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity,
                   restorationHandler: ([AnyObject]?) -> Void) -> Bool {

    return self.viewModel.inputs.applicationContinueUserActivity(userActivity)
  }

  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,
                   annotation: AnyObject) -> Bool {

    return self.viewModel.inputs.applicationOpenUrl(application: application,
                                                    url: url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
  }

  internal func application(application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    self.viewModel.inputs.didRegisterForRemoteNotifications(withDeviceTokenData: deviceToken)
  }

  internal func application(application: UIApplication,
                            didReceiveRemoteNotification userInfo: [NSObject: AnyObject]) {

    self.viewModel.inputs.didReceive(remoteNotification: userInfo,
                                     applicationIsActive: application.applicationState == .Active)
  }

  internal func application(application: UIApplication,
                            didReceiveLocalNotification notification: UILocalNotification) {

    if let userInfo = notification.userInfo where userInfo["aps"] != nil {
      self.viewModel.inputs.didReceive(remoteNotification: userInfo,
                                       applicationIsActive: application.applicationState == .Active)
    }
  }

  private func presentRemoteNotificationAlert(message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)

    alert.addAction(
      UIAlertAction(title: Strings.View(), style: .Default) { [weak self] _ in
        self?.viewModel.inputs.openRemoteNotificationTappedOk()
      }
    )

    alert.addAction(
      UIAlertAction(title: Strings.Dismiss(), style: .Cancel, handler: nil)
    )

    self.rootTabBarController?.presentViewController(alert, animated: true, completion: nil)
  }
}
