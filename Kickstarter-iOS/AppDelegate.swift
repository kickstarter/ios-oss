import BrazeKit
import BrazeUI
//import BrazeKitResources
//import BrazeLocation
import AppCenter
import AppCenterDistribute
import FBSDKCoreKit
import Firebase
import Foundation
#if DEBUG
  @testable import KsApi
#else
  import KsApi
#endif
import Segment
import SegmentBrazeUI
import Kickstarter_Framework
import Library
import Prelude
import ReactiveExtensions
import ReactiveSwift
import SafariServices
import UIKit
import UserNotifications

@UIApplicationMain
internal final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  fileprivate let viewModel: AppDelegateViewModelType = AppDelegateViewModel()
  internal var rootTabBarController: RootTabBarViewController? {
    return self.window?.rootViewController as? RootTabBarViewController
  }
  
  private var analytics: Segment.Analytics?
  public internal(set) var braze: Braze? = nil

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // FBSDK initialization
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    Settings.shouldLimitEventAndDataUsage = true

    UIView.doBadSwizzleStuff()
    UIViewController.doBadSwizzleStuff()

    UIImageView.appearance(whenContainedInInstancesOf: [UITabBar.self])
      .accessibilityIgnoresInvertColors = true

    AppEnvironment.replaceCurrentEnvironment(
      AppEnvironment.fromStorage(
        ubiquitousStore: NSUbiquitousKeyValueStore.default,
        userDefaults: UserDefaults.standard
      )
    )

    #if DEBUG
      if KsApi.Secrets.isOSS {
        AppEnvironment.replaceCurrentEnvironment(apiService: MockService())
      }
    #endif

    self.viewModel.outputs.updateCurrentUserInEnvironment
      .observeForUI()
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        AppEnvironment.current.ksrAnalytics.identify(newUser: user)
        self?.viewModel.inputs.currentUserUpdatedInEnvironment()
        
        if let braze = self?.braze {
          braze.changeUser(userId: String(user.id))
        }
      }

    self.viewModel.outputs.forceLogout
      .observeForUI()
      .observeValues {
        AppEnvironment.logout()
        NotificationCenter.default.post(.init(name: .ksr_sessionEnded, object: nil))
      }

    self.viewModel.outputs.updateConfigInEnvironment
      .observeForUI()
      .observeValues { [weak self] config in
        AppEnvironment.updateConfig(config)

        self?.viewModel.inputs.didUpdateConfig(config)
      }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues(NotificationCenter.default.post)

    self.viewModel.outputs.presentViewController
      .observeForUI()
      .observeValues { [weak self] in
        self?.rootTabBarController?.dismiss(animated: true, completion: nil)
        self?.rootTabBarController?.present($0, animated: true, completion: nil)
      }

    self.viewModel.outputs.goToDiscovery
      .observeForUI()
      .observeValues { [weak self] in self?.rootTabBarController?.switchToDiscovery(params: $0) }

    self.viewModel.outputs.goToActivity
      .observeForUI()
      .observeValues { [weak self] in self?.rootTabBarController?.switchToActivities() }

    self.viewModel.outputs.goToLoginWithIntent
      .observeForControllerAction()
      .observeValues { [weak self] intent in
        let vc = LoginToutViewController.configuredWith(loginIntent: intent)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet

        self?.rootTabBarController?.present(nav, animated: true, completion: nil)
      }

    self.viewModel.outputs.goToMessageThread
      .observeForUI()
      .observeValues { [weak self] in self?.goToMessageThread($0) }

    self.viewModel.outputs.goToSearch
      .observeForUI()
      .observeValues { [weak self] in self?.rootTabBarController?.switchToSearch() }

    self.viewModel.outputs.goToMobileSafari
      .observeForUI()
      .observeValues { UIApplication.shared.open($0) }

    self.viewModel.outputs.applicationIconBadgeNumber
      .observeForUI()
      .observeValues { UIApplication.shared.applicationIconBadgeNumber = $0 }

    self.viewModel.outputs.pushTokenRegistrationStarted
      .observeForUI()
      .observeValues {
        print("📲 [Push Registration] Push token registration started 🚀")
      }

    self.viewModel.outputs.pushTokenSuccessfullyRegistered
      .observeForUI()
      .observeValues { token in
        print("📲 [Push Registration] Push token successfully registered (\(token)) ✨")
      }

    self.viewModel.outputs.registerPushTokenInSegment
      .observeForUI()
      .observeValues { [weak self] token in
        guard let self = self else { return }
        self.analytics?.registeredForRemoteNotifications(deviceToken: token)
      }

    self.viewModel.outputs.showAlert
      .observeForUI()
      .observeValues { [weak self] in
        self?.presentContextualPermissionAlert($0)
      }

    self.viewModel.outputs.unregisterForRemoteNotifications
      .observeForUI()
      .observeValues(UIApplication.shared.unregisterForRemoteNotifications)

    self.viewModel.outputs.configureAppCenterWithData
      .observeForUI()
      .observeValues { data in
        AppCenter.userId = data.userId

        AppCenter.start(
          withAppSecret: data.appSecret,
          services: [
            Distribute.self
          ]
        )
      }

    #if RELEASE || APPCENTER
      self.viewModel.outputs.configureFirebase
        .observeForUI()
        .observeValues { [weak self] in
          guard let strongSelf = self else { return }

          FirebaseApp.configure()
          AppEnvironment.current.ksrAnalytics.logEventCallback = { event, _ in
            Crashlytics.crashlytics().log(format: "%@", arguments: getVaList([event]))
          }

          strongSelf.configureRemoteConfig()
        }
    #endif

    self.viewModel.outputs.synchronizeUbiquitousStore
      .observeForUI()
      .observeValues {
        _ = AppEnvironment.current.ubiquitousStore.synchronize()
      }

    self.viewModel.outputs.setApplicationShortcutItems
      .observeForUI()
      .observeValues { shortcutItems in
        UIApplication.shared.shortcutItems = shortcutItems.map { $0.applicationShortcutItem }
      }

    self.viewModel.outputs.findRedirectUrl
      .observeForUI()
      .observeValues { [weak self] in self?.findRedirectUrl($0) }

    self.viewModel.outputs.emailVerificationCompleted
      .observeForUI()
      .observeValues { [weak self] message, success in
        self?.rootTabBarController?.dismiss(animated: false, completion: nil)
        self?.rootTabBarController?
          .messageBannerViewController?.showBanner(with: success ? .success : .error, message: message)
      }

    NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
      }

    NotificationCenter.default
      .addObserver(
        forName: Notification.Name.ksr_showNotificationsDialog, object: nil, queue: nil
      ) { [weak self] in
        self?.viewModel.inputs.showNotificationDialog(notification: $0)
      }

    NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
      }

    self.viewModel.outputs.configureSegmentWithBraze
      .observeForUI()
      .observeValues { [weak self] writeKey in
        guard let self else { return }
        
        let brazeDestination = BrazeDestination(
          additionalConfiguration: { configuration in
            configuration.triggerMinimumTimeInterval = 5
            configuration.push.automation = false
            configuration.logger.level = .debug
//            configuration.push.automation.requestAuthorizationAtLaunch = false
//            configuration.push.automation.handleBackgroundNotification = false
          }) { [weak self] braze in
            guard let self else { return }
            self.braze = braze
            braze.delegate = self
            if let userId = AppEnvironment.current.currentUser?.id {
              braze.changeUser(userId: String(userId))
            }
//            braze.notifications.subscribeToUpdates { [weak self] payload in
//              guard let self else { return }
//              if let rootTabBarController = self.rootTabBarController {
//                // Handle notification, including any deeplinks.
//                self.viewModel.inputs.didReceive(remoteNotification: payload.userInfo)
//                rootTabBarController.didReceiveBadgeValue(payload.badge)
//              }
//            }

            let inAppMessageUI = BrazeInAppMessageUI()
            inAppMessageUI.delegate = self
            braze.inAppMessagePresenter = inAppMessageUI
          }
        
        let analytics = Analytics.configuredAnalytics(withWriteKey: writeKey, brazeDestination: brazeDestination)
        
        self.analytics = analytics
        AppEnvironment.current.ksrAnalytics.configureSegmentClient(analytics)
      }

    self.viewModel.outputs.segmentIsEnabled
      .observeValues { [weak self] enabled in
        guard let self else { return }
        self.analytics?.enabled = enabled
      }

    NotificationCenter.default
      .addObserver(
        forName: Notification.Name.ksr_configUpdated,
        object: nil,
        queue: nil
      ) { [weak self] _ in
        self?.viewModel.inputs.configUpdatedNotificationObserved()
      }

    self.window?.tintColor = .ksr_create_700

    self.viewModel.inputs.applicationDidFinishLaunching(
      application: application,
      launchOptions: launchOptions
    )

    UNUserNotificationCenter.current().delegate = self

    return self.viewModel.outputs.applicationDidFinishLaunchingReturnValue
  }

  func applicationDidBecomeActive(_: UIApplication) {
    self.viewModel.inputs.applicationActive(state: true)
  }

  func applicationWillResignActive(_: UIApplication) {
    self.viewModel.inputs.applicationActive(state: false)
  }

  func applicationWillEnterForeground(_: UIApplication) {
    self.viewModel.inputs.applicationWillEnterForeground()
  }

  func applicationDidEnterBackground(_: UIApplication) {
    self.viewModel.inputs.applicationDidEnterBackground()
  }

  func application(
    _: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    return self.viewModel.inputs.applicationContinueUserActivity(userActivity)
  }

  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // If this is not a Facebook login call, handle the potential deep-link
    guard !ApplicationDelegate.shared.application(app, open: url, options: options) else {
      return true
    }

    return self.viewModel.inputs.applicationOpenUrl(
      application: app,
      url: url,
      options: options
    )
  }

  // MARK: - Remote notifications

  internal func application(
    _: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    self.viewModel.inputs.didRegisterForRemoteNotifications(withDeviceTokenData: deviceToken)
    if let braze = self.braze {
      braze.notifications.register(deviceToken: deviceToken)
    }
  }

  internal func application(
    _: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("🔴 Failed to register for remote notifications: \(error.localizedDescription)")
  }

  func application(
    _: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    self.analytics?.receivedRemoteNotification(userInfo: userInfo)
    completionHandler(.noData)
  }

  internal func applicationDidReceiveMemoryWarning(_: UIApplication) {
    self.viewModel.inputs.applicationDidReceiveMemoryWarning()
  }

  internal func application(
    _: UIApplication,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    self.viewModel.inputs.applicationPerformActionForShortcutItem(shortcutItem)
    completionHandler(true)
  }

  // MARK: - Functions

  fileprivate func presentContextualPermissionAlert(_ notification: Notification) {
    guard let context = notification.userInfo?.values.first as? PushNotificationDialog.Context else {
      return
    }

    let alert = UIAlertController(title: context.title, message: context.message, preferredStyle: .alert)

    alert.addAction(
      UIAlertAction(title: Strings.project_star_ok(), style: .default) { [weak self] _ in
        self?.viewModel.inputs.didAcceptReceivingRemoteNotifications()
      }
    )

    alert.addAction(
      UIAlertAction(title: PushNotificationDialog.titleForDismissal, style: .cancel, handler: { _ in
        PushNotificationDialog.didDenyAccess(for: context)
      })
    )

    // Sometimes, the "sign up for push" popup doesn't appear when you sign in via web authentication session.
    // My best guess is that this happens because the dismissal of the web login screen accidentally dismisses this popup, too.
    // The delay isn't pretty, but it works.

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      if let viewController = notification.userInfo?[UserInfoKeys.viewController] as? UIViewController {
        viewController.present(alert, animated: true, completion: nil)
      } else {
        self.rootTabBarController?.present(alert, animated: true, completion: nil)
      }
    }
  }

  private func goToMessageThread(_ messageThread: MessageThread) {
    self.rootTabBarController?.switchToMessageThread(messageThread)
  }

  private func findRedirectUrl(_ url: URL) {
    let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    let task = session.dataTask(with: url)
    task.resume()
  }

  private func configureRemoteConfig() {
    let remoteConfigClient = RemoteConfigClient(with: RemoteConfig.remoteConfig())

    AppEnvironment.updateRemoteConfigClient(remoteConfigClient)

    self.fetchAndActivateRemoteConfig()

    _ = AppEnvironment.current.remoteConfigClient?
      .addOnConfigUpdateListener { configUpdate, error in
        guard let realtimeUpdateError = error else {
          print("🔮 Remote Config Keys Update: \(String(describing: configUpdate?.updatedKeys))")

          return
        }

        print(
          "🔴 Remote Config SDK Config Update Listener Failure: \(realtimeUpdateError.localizedDescription)"
        )
      }
  }

  private func fetchAndActivateRemoteConfig() {
    AppEnvironment.current.remoteConfigClient?.fetchAndActivate { _, error in
      guard let remoteConfigActivationError = error else {
        print("🔮 Remote Config SDK Successfully Activated")

        self.viewModel.inputs.didUpdateRemoteConfigClient()
        return
      }

      let errorAsNSError = remoteConfigActivationError as NSError

      if errorAsNSError.domain == RemoteConfigErrorDomain,
         errorAsNSError.code == RemoteConfigError.internalError.rawValue {
        // This is (almost certainly) just a connection error; we won't log it.
      } else {
        Crashlytics.crashlytics().record(error: remoteConfigActivationError)
      }

      print(
        "🔴 Remote Config SDK Activation Failed with Error: \(remoteConfigActivationError.localizedDescription)"
      )

      self.viewModel.inputs.remoteConfigClientConfigurationFailed()
    }
  }
}

// MARK: - URLSessionTaskDelegate

extension AppDelegate: URLSessionTaskDelegate {
  public func urlSession(
    _: URLSession,
    task _: URLSessionTask,
    willPerformHTTPRedirection _: HTTPURLResponse,
    newRequest request: URLRequest,
    completionHandler: @escaping (URLRequest?) -> Void
  ) {
    request.url.doIfSome(self.viewModel.inputs.foundRedirectUrl)
    completionHandler(nil)
  }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
  public func userNotificationCenter(
    _: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    self.rootTabBarController?.didReceiveBadgeValue(notification.request.content.badge as? Int)
    completionHandler([.banner, .list])
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completion: @escaping () -> Void
  ) {
    if let rootTabBarController = self.rootTabBarController {
      // Handle notification, including any deeplinks.
      self.viewModel.inputs.didReceive(remoteNotification: response.notification.request.content.userInfo)
      rootTabBarController.didReceiveBadgeValue(response.notification.request.content.badge as? Int)
    }

    // Tell Braze about notification.
    
//    self.braze?.notifications.handleUserNotification(response: response, withCompletionHandler: {
//      return
//    })
    
    if let braze = self.braze, braze.notifications.handleUserNotification(
      response: response,
      withCompletionHandler: completion) {
      return // Braze called completion.
    }
    // Braze didn't call completion.
    completion()
  }
}

// MARK: - BrazeInAppMessageUIDelegate

extension AppDelegate: BrazeInAppMessageUIDelegate {
  func inAppMessage(
    _ ui: BrazeInAppMessageUI,
    displayChoiceForMessage message: Braze.InAppMessage
  ) -> BrazeInAppMessageUI.DisplayChoice {
    return self.viewModel.inputs.brazeWillDisplayInAppMessage(message)
  }
}

// MARK: - BrazeDelegate

extension AppDelegate: BrazeDelegate {
  func braze(_ braze: BrazeKit.Braze, shouldOpenURL context: BrazeKit.Braze.URLContext) -> Bool {
    self.viewModel.inputs.urlFromBrazeInAppNotification(context.url)

    return true
  }
}
