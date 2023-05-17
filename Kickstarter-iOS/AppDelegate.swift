import AppboyKit
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
import AppboySegment
import Kickstarter_Framework
import Library
import Prelude
import ReactiveExtensions
import ReactiveSwift
import SafariServices
import Segment
import UIKit
import UserNotifications

@UIApplicationMain
internal final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  fileprivate let viewModel: AppDelegateViewModelType = AppDelegateViewModel()
  internal var rootTabBarController: RootTabBarViewController? {
    return self.window?.rootViewController as? RootTabBarViewController
  }

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

    self.viewModel.outputs.goToDashboard
      .observeForUI()
      .observeValues { [weak self] in self?.rootTabBarController?.switchToDashboard(project: $0) }

    self.viewModel.outputs.goToCreatorMessageThread
      .observeForUI()
      .observeValues { [weak self] in
        self?.goToCreatorMessageThread($0, $1)
      }

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

    self.viewModel.outputs.goToProjectActivities
      .observeForUI()
      .observeValues { [weak self] in
        self?.goToProjectActivities($0)
      }

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
      .observeValues { token in
        Analytics.shared().registeredForRemoteNotifications(withDeviceToken: token)
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
      .observeValues { [weak self] writeKey in
        guard let strongSelf = self else { return }

        let (configuration, appBoyInstance) = Analytics.configuredClient(withWriteKey: writeKey)

        appBoyInstance?.saveLaunchOptions(launchOptions)
        appBoyInstance?.appboyOptions = [
          ABKInAppMessageControllerDelegateKey: strongSelf,
          ABKURLDelegateKey: strongSelf,
          ABKMinimumTriggerTimeIntervalKey: 5
        ]

        Analytics.setup(with: configuration)

        AppEnvironment.current.ksrAnalytics.configureSegmentClient(Analytics.shared())
      }

    self.viewModel.outputs.configureFeatureFlagClient
      .observeValues { [weak self] featureFlagClient in
        guard let strongSelf = self else { return }

        // TODO: Will remove this method and input/output with the full removal of Optimizely code
        AppEnvironment.updateOptimizelyClient(featureFlagClient)

        strongSelf.viewModel.inputs.didUpdateRemoteConfigClient()
      }

    self.viewModel.outputs.segmentIsEnabled
      .observeValues { enabled in
        enabled ? Analytics.shared().enable() : Analytics.shared().disable()
      }

    NotificationCenter.default
      .addObserver(
        forName: Notification.Name.ksr_configUpdated,
        object: nil,
        queue: nil
      ) { [weak self] _ in
        self?.viewModel.inputs.configUpdatedNotificationObserved()
      }

    NotificationCenter.default
      .addObserver(
        forName: Notification.Name.ksr_perimeterXCaptcha,
        object: nil,
        queue: nil
      ) { [weak self] note in
        self?.viewModel.inputs.perimeterXCaptchaTriggeredWithUserInfo(note.userInfo)
      }

    self.window?.tintColor = .ksr_create_700

    self.viewModel.inputs.applicationDidFinishLaunching(
      application: application,
      launchOptions: launchOptions
    )

    self.viewModel.outputs.goToPerimeterXCaptcha
      .observeForControllerAction()
      .observeValues { response in
        self.goToPerimeterXCaptcha(response)
      }

    UNUserNotificationCenter.current().delegate = self

    return self.viewModel.outputs.applicationDidFinishLaunchingReturnValue
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
    fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    SEGAppboyIntegrationFactory.instance()?.saveRemoteNotification(userInfo)
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

    DispatchQueue.main.async {
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

  private func goToPerimeterXCaptcha(_ response: PerimeterXBlockResponseType) {
    response
      .displayCaptcha(
        on: AppEnvironment.current.apiService.perimeterXClient,
        vc: self.window?.rootViewController
      )
  }

  private func goToCreatorMessageThread(_ projectId: Param, _ messageThread: MessageThread) {
    self.rootTabBarController?
      .switchToCreatorMessageThread(projectId: projectId, messageThread: messageThread)
  }

  private func goToProjectActivities(_ projectId: Param) {
    self.rootTabBarController?.switchToProjectActivities(projectId: projectId)
  }

  private func findRedirectUrl(_ url: URL) {
    let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    let task = session.dataTask(with: url)
    task.resume()
  }

  private func configureRemoteConfig() {
    let remoteConfigClient = RemoteConfigClient(with: RemoteConfig.remoteConfig())

    AppEnvironment.updateRemoteConfigClient(remoteConfigClient)

    let appDefaults: [String: Any?] = [
      RemoteConfigFeature.consentManagementDialogEnabled.rawValue: false,
      RemoteConfigFeature.facebookLoginInterstitialEnabled.rawValue: false
    ]

    AppEnvironment.current.remoteConfigClient?.setDefaults(appDefaults as? [String: NSObject])

    AppEnvironment.current.remoteConfigClient?.activate { _, error in
      guard let remoteConfigActivationError = error else {
        print("🔮 Remote Config SDK Successfully Activated")

        self.viewModel.inputs.didUpdateRemoteConfigClient()
        return
      }

      print("🔴 Remote Config SDK Activation Failed with Error: \(remoteConfigActivationError.localizedDescription)")

      Crashlytics.crashlytics().record(error: remoteConfigActivationError)

      self.viewModel.inputs.remoteConfigClientConfigurationFailed()
    }

    AppEnvironment.current.remoteConfigClient?.fetch { _, _ in }

    _ = AppEnvironment.current.remoteConfigClient?.addOnConfigUpdateListener { _, error in
      guard let realtimeUpdateError = error else {
        print("🔮 Remote Config Key/Value Pair Updated")

        return
      }

      print("🔴 Remote Config SDK Config Update Listener Failure: \(realtimeUpdateError.localizedDescription)")
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
    _: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completion: @escaping () -> Void
  ) {
    guard let rootTabBarController = self.rootTabBarController else {
      completion()
      return
    }

    self.viewModel.inputs.didReceive(remoteNotification: response.notification.request.content.userInfo)
    rootTabBarController.didReceiveBadgeValue(response.notification.request.content.badge as? Int)
    completion()
  }
}

// MARK: - ABKInAppMessageControllerDelegate

extension AppDelegate: ABKInAppMessageControllerDelegate {
  func before(inAppMessageDisplayed inAppMessage: ABKInAppMessage) -> ABKInAppMessageDisplayChoice {
    return self.viewModel.inputs.brazeWillDisplayInAppMessage(inAppMessage)
  }
}

// MARK: - ABKURLDelegate

extension AppDelegate: ABKURLDelegate {
  func handleAppboyURL(_ url: URL?, from _: ABKChannel, withExtras _: [AnyHashable: Any]?) -> Bool {
    self.viewModel.inputs.urlFromBrazeInAppNotification(url)

    return true
  }
}
