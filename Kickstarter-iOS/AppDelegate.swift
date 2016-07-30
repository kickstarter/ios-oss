import FBSDKCoreKit
import Foundation
import KsApi
import Kickstarter_Framework
import ReactiveCocoa
import Result
import ReactiveExtensions
import Library
import Prelude
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  let viewModel: AppDelegateViewModelType = AppDelegateViewModel()

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

    self.viewModel.outputs.updateEnvironment
      .observeForUI()
      .observeNext { config, koala in
        AppEnvironment.replaceCurrentEnvironment(config: config, koala: koala)
    }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)

    self.window?.tintColor = .ksr_navy_700

    viewModel.inputs.applicationDidFinishLaunching(application: application, launchOptions: launchOptions)

    return true
  }

  func applicationWillEnterForeground(application: UIApplication) {
    self.viewModel.inputs.applicationWillEnterForeground()
  }

  func applicationDidEnterBackground(application: UIApplication) {
    self.viewModel.inputs.applicationDidEnterBackground()
  }

  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,
                   annotation: AnyObject) -> Bool {

    self.viewModel.inputs.applicationOpenUrl(application: application,
                                             url: url,
                                             sourceApplication: sourceApplication,
                                             annotation: annotation)

    return self.viewModel.outputs.facebookOpenURLReturnValue.value
  }
}
