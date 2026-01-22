import BrazeKit
import BrazeUI
import Firebase
import Foundation
import KDS
#if DEBUG
  @testable import KsApi
  @testable import KsApiTestHelpers
#else
  import KsApi
#endif
import Kickstarter_Framework
import Library
import Prelude
import ReactiveExtensions
import ReactiveSwift
import SafariServices
import Segment
import SegmentBrazeUI
import SwiftUI
import UIKit
import UserNotifications

@UIApplicationMain
internal final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  fileprivate let viewModel: AppDelegateViewModelType = AppDelegateViewModel()
  fileprivate var disposables: [any Disposable] = []
  // Custom Braze cancellable type. As long as we keep a reference to this active, Braze will
  // use this to tell us about any Braze push notifications the app handles.
  fileprivate var brazeSubscription: BrazeKit.Braze.Cancellable?

  private var analytics: Segment.Analytics?
  private weak var braze: Braze?

  internal var rootTabBarController: RootTabBarViewController? {
    return self.window?.rootViewController as? RootTabBarViewController
  }

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // FBSDK initialization
    let facebookAppID = Bundle.main.infoDictionary?["FacebookAppID"] as? String
    AppEnvironment.configureFacebookSDK(
      appID: facebookAppID,
      application: application,
      launchOptions: launchOptions
    )

    // Braze expects to be configured immediately, but segment destination plugins are initialized
    // async. This method bridges that gap.
    // https://www.braze.com/docs/developer_guide/sdk_integration#swift_step-2-set-up-delayed-initialization-optional
    Braze.prepareForDelayedInitialization(pushAutomation: self.configuredBrazePushAutomation())

    UIView.doBadSwizzleStuff()
    UIViewController.doBadSwizzleStuff()

    UIImageView.appearance(whenContainedInInstancesOf: [UITabBar.self])
      .accessibilityIgnoresInvertColors = true

    InterFont.registerFontIfUnregistered()

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
        // Update user in Braze.
        self?.braze?.changeUser(userId: String(user.id))
        // Update user in Segment.
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
        $0.modalPresentationStyle = .pageSheet
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
        /// Dismiss OnboardingView if present so that we can correctly present the LoginToutViewController.
        if let onboardingView = self?.rootTabBarController?
          .presentedViewController as? UIHostingController<OnboardingView> {
          onboardingView.dismiss(animated: true)
          AppEnvironment.current.userDefaults.set(true, forKey: AppKeys.hasSeenOnboarding.rawValue)
        }

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

    self.viewModel.outputs.registerPushTokenInBraze
      .observeForUI()
      .observeValues { token in
        self.braze?.notifications.register(deviceToken: token)
      }

    self.viewModel.outputs.triggerOnboardingFlow
      .observeForUI()
      .observeValues { [weak self] in
        guard let rootTabBarController = self?.rootTabBarController else { return }

        let onboardingVC = UIHostingController(rootView: OnboardingView(viewModel: OnboardingViewModel()))
        /// Onboarding flow should not respond to light/dark mode preference.
        onboardingVC.overrideUserInterfaceStyle = .light
        onboardingVC.modalPresentationStyle = .fullScreen

        rootTabBarController.navigationController?.isNavigationBarHidden = true
        rootTabBarController.present(onboardingVC, animated: true, completion: nil)
      }

    NotificationCenter.default
      .addObserver(
        forName: Notification.Name.ksr_goToLoginFromOnboarding,
        object: nil,
        queue: nil
      ) { [weak self] _ in
        self?.viewModel.inputs.goToLoginSignup(from: .onboarding)
      }

    self.viewModel.outputs.showAlert
      .observeForUI()
      .observeValues { [weak self] in
        self?.presentContextualPermissionAlert($0)
      }

    self.viewModel.outputs.unregisterForRemoteNotifications
      .observeForUI()
      .observeValues(UIApplication.shared.unregisterForRemoteNotifications)

    #if RELEASE || INTERNAL_BUILD
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

    self.disposables.append(
      self.viewModel.outputs.trackingAuthorizationStatus
        .observeForUI()
        .startWithValues(self.updateFirebaseConsent(status:))
    )

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
        guard let self else { return }

        let configuration = Analytics.configuredClient(withWriteKey: writeKey)
        let brazeDestination = self.configuredBrazeDestination(for: configuration)
        configuration.add(plugin: brazeDestination)

        let middleware = BrazeDebounceMiddlewarePlugin()
        configuration.add(plugin: middleware)

        self.analytics = configuration

        AppEnvironment.current.ksrAnalytics.configureSegmentClient(configuration)
      }

    self.viewModel.outputs.segmentIsEnabled
      .observeValues { enabled in
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

    self.window?.tintColor = LegacyColors.ksr_create_700.uiColor()

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
    guard !AppEnvironment.current.facebookSDK.handleOpenURL(app, open: url, options: options) else {
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

  private func updateFirebaseConsent(status: AppTrackingAuthorization) {
    // https://developers.google.com/tag-platform/security/guides/app-consent?platform=ios&consentmode=advanced
    let consentStatus: ConsentStatus = if case .authorized = status {
      .granted
    } else {
      .denied
    }
    Analytics.setConsent([
      .analyticsStorage: consentStatus,
      .adStorage: consentStatus,
      .adUserData: consentStatus,
      .adPersonalization: consentStatus
    ])
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

  private func configuredBrazeDestination(for configuration: Segment.Analytics) -> BrazeDestination {
    return BrazeDestination(
      additionalConfiguration: { configuration in
        configuration.triggerMinimumTimeInterval = 5
        configuration.push.automation = self.configuredBrazePushAutomation()
        // TODO(MBL-2742): Change the logger level to `info` or `error` if it gets tedious.
        configuration.logger.level = .debug
      }
    ) { [weak self] braze in
      guard let self else { return }
      braze.delegate = self
      self.braze = braze

      braze.inAppMessagePresenter = BrazeUI.BrazeInAppMessageUI()

      if let userId = AppEnvironment.current.currentUser?.id {
        braze.changeUser(userId: String(userId))
      }

      // This block of code gets called anytime a Braze notification is opened.
      // AWS notifications will not trigger this code.
      self.brazeSubscription = braze.notifications
        .subscribeToUpdates(payloadTypes: [.opened]) { [weak self] payload in
          guard let self else { return }
          // TODO(MBL-2742): Once the migration is stable, revisit if Braze should update the
          // rootTabBar. If not, this block can be deleted.
          if let rootTabBarController = self.rootTabBarController {
            rootTabBarController.didReceiveBadgeValue(payload.badge)
          }
        }
    }
  }

  // This configuration object defines how much automation Braze does. It gets set both when
  // we configure `BrazeDestination` and when we call `Braze.prepareForDelayedInitialization`.
  // https://braze-inc.github.io/braze-swift-sdk/documentation/brazekit/braze/configuration-swift.class/push-swift.class/automation-swift.class/
  private func configuredBrazePushAutomation() -> BrazeKit.Braze.Configuration.Push.Automation {
    let automation: BrazeKit.Braze.Configuration.Push.Automation = true
    automation.automaticSetup = false
    automation.requestAuthorizationAtLaunch = false
    automation.registerDeviceToken = false
    return automation
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
    // Handle AWS foreground notification.
    // Braze notifications will not trigger this delegate method.
    self.rootTabBarController?.didReceiveBadgeValue(notification.request.content.badge as? Int)
    completionHandler([.banner, .list])
  }

  func userNotificationCenter(
    _: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completion: @escaping () -> Void
  ) {
    // Handle AWS notification opened.
    // Braze notifications will not trigger this delegate method.
    guard let rootTabBarController = self.rootTabBarController else {
      completion()
      return
    }

    self.viewModel.inputs.didReceive(remoteNotification: response.notification.request.content.userInfo)
    rootTabBarController.didReceiveBadgeValue(response.notification.request.content.badge as? Int)
    completion()
  }
}

// MARK: - BrazeDelegate

extension AppDelegate: BrazeDelegate {
  // Intercept all URLs from Braze in-app messages or push notifications.
  // AWS notifications will not trigger this delegate method.
  func braze(_: BrazeKit.Braze, shouldOpenURL context: BrazeKit.Braze.URLContext) -> Bool {
    // Custom handle all urls instead of letting braze try to open them.
    self.viewModel.inputs.urlFromBrazeNotification(context.url)
    return false
  }
}
