import UIKit
import KsApi
import Library
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  let viewModel: AppDelegateViewModelType

  override init() {
    AppEnvironment.pushEnvironment(
      AppEnvironment.fromStorage(
        ubiquitousStore: NSUbiquitousKeyValueStore.defaultStore(),
        userDefaults: NSUserDefaults.standardUserDefaults()
      )
    )
    self.viewModel = AppDelegateViewModel()

    super.init()

    self.viewModel.outputs.updateCurrentUserInEnvironment
      .observeForUI()
      .observeNext { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        self?.viewModel.inputs.currentUserUpdatedInEnvironment()
    }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)
  }

  func application(application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    viewModel.inputs.applicationDidFinishLaunching(launchOptions: launchOptions)

    return true
  }

  func applicationWillEnterForeground(application: UIApplication) {
    self.viewModel.inputs.applicationWillEnterForeground()
  }

  func applicationDidEnterBackground(application: UIApplication) {
    self.viewModel.inputs.applicationDidEnterBackground()
  }
}
