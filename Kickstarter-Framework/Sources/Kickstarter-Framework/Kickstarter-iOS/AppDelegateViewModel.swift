import Experimentation
import FirebaseCrashlytics
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit
import UserNotifications

public enum NotificationAuthorizationStatus {
  case authorized
  case denied
  case notDetermined
  case provisional
}

public protocol AppDelegateViewModelInputs {
  /// Call when the application finishes launching.
  func applicationDidFinishLaunching(
    application: UIApplication?, launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  )

  /// Call when the application will enter foreground.
  func applicationWillEnterForeground()

  /// Call when the application enters background.
  func applicationDidEnterBackground()

  /// Call when the application becomes active `UIApplicationStateActive` and `UIApplicationStateInactive`
  func applicationActive(state: Bool)

  /// Call when the aplication receives memory warning from the system.
  func applicationDidReceiveMemoryWarning()

  /// Call after having invoked AppEnvironment.updateCurrentUser with a fresh user.
  func currentUserUpdatedInEnvironment()

  /// Call when the `ksr_configUpdated` notification is observed (config updated elsewhere, eg. debug tools).
  func configUpdatedNotificationObserved()

  /// Call when the user taps "OK" from the contextual alert.
  func didAcceptReceivingRemoteNotifications()

  /// Call when the app delegate receives a remote notification.
  func didReceive(remoteNotification notification: [AnyHashable: Any])

  /// Call when the app delegate gets notice of a successful notification registration.
  func didRegisterForRemoteNotifications(withDeviceTokenData data: Data)

  /// Call when the config has been updated the AppEnvironment
  func didUpdateConfig(_ config: Config)

  /// Call when the Remote Config client has been updated in the AppEnvironment
  func didUpdateRemoteConfigClient()

  /// Call when the users taps 'Log in or Sign up' from the onboarding flow (`OnboardingView`).
  func goToLoginSignup(from intent: LoginIntent)

  /// Call when Remote Config configuration has failed
  func remoteConfigClientConfigurationFailed()

  /// Call when the contextual PushNotification dialog should be presented.
  func showNotificationDialog(notification: Notification)

  /// Call when Braze in-app notifications send a valid URL.
  func urlFromBrazeNotification(_ url: URL?)

  /// Call when the controller has received a user session ended notification.
  func userSessionEnded()

  /// Call when the controller has received a user session started notification.
  func userSessionStarted()
}

public protocol AppDelegateViewModelOutputs {
  /// The value to return from the delegate's `application:didFinishLaunchingWithOptions:` method.
  var applicationDidFinishLaunchingReturnValue: Bool { get }

  /// Emits the application icon badge number
  var applicationIconBadgeNumber: Signal<Int, Never> { get }

  /// Emits when the application should configure Firebase
  var configureFirebase: Signal<(), Never> { get }

  /// Emits when the application should configure Segment with an instance of Braze.
  var configureSegmentWithBraze: Signal<String, Never> { get }

  /// Emits when the application should configure Statsig
  var configureStatsig: Signal<StatsigClientSDKKey, Never> { get }

  /// Emits when opening the app with an invalid access token.
  var forceLogout: Signal<(), Never> { get }

  /// Emits when the root view controller should navigate to activity.
  var goToActivity: Signal<(), Never> { get }

  /// Emits when the root view controller should navigate to the discovery screen.
  var goToDiscovery: Signal<DiscoveryParams?, Never> { get }

  /// Emits when the root view controller should present the login modal.
  var goToLoginWithIntent: Signal<LoginIntent, Never> { get }

  /// Emits a message thread when we should navigate to it.
  var goToMessageThread: Signal<MessageThread, Never> { get }

  /// Emits a URL when we should open it in the safari browser.
  var goToMobileSafari: Signal<URL, Never> { get }

  /// Emits an Notification that should be immediately posted.
  var postNotification: Signal<Notification, Never> { get }

  /// Emits when a view controller should be presented.
  var presentViewController: Signal<UIViewController, Never> { get }

  /// Emits when the push token registration begins.
  var pushTokenRegistrationStarted: Signal<(), Never> { get }

  /// Emits the push token that has been successfully registered on the server.
  var pushTokenSuccessfullyRegistered: Signal<String, Never> { get }

  /// Emits when we should register the device push token in Braze.
  var registerPushTokenInBraze: Signal<Data, Never> { get }

  /// Emits when application didFinishLaunchingWithOptions.
  var requestATTrackingAuthorizationStatus: Signal<Void, Never> { get }

  /// Emits when our config updates with the enabled state for Semgent Analytics.
  var segmentIsEnabled: Signal<Bool, Never> { get }

  /// Emits an array of short cut items to put into the shared application.
  var setApplicationShortcutItems: Signal<[ShortcutItem], Never> { get }

  /// Emits when an alert should be shown.
  var showAlert: Signal<Notification, Never> { get }

  /// Emits to synchronize iCloud on app launch.
  var synchronizeUbiquitousStore: Signal<(), Never> { get }

  /// Emits immediately and when the user's authorization status changes
  var trackingAuthorizationStatus: SignalProducer<AppTrackingAuthorization, Never> { get }

  /// Emits when application didFinishLaunchingWithOptions and the Onboarding Flow feature flag is enabled.
  var triggerOnboardingFlow: Signal<(), Never> { get }

  /// Emits when we should unregister the user from notifications.
  var unregisterForRemoteNotifications: Signal<(), Never> { get }

  /// Emits a fresh user to be updated in the app environment.
  var updateCurrentUserInEnvironment: Signal<User, Never> { get }

  /// Emits a config value that should be updated in the environment.
  var updateConfigInEnvironment: Signal<Config, Never> { get }
}

public protocol AppDelegateViewModelType {
  var inputs: AppDelegateViewModelInputs { get }
  var outputs: AppDelegateViewModelOutputs { get }
}

public final class AppDelegateViewModel: AppDelegateViewModelType, AppDelegateViewModelInputs,
  AppDelegateViewModelOutputs {
  public init() {
    let currentUserEvent = Signal
      .merge(
        self.applicationWillEnterForegroundProperty.signal,
        self.applicationLaunchOptionsProperty.signal.ignoreValues(),
        self.userSessionEndedProperty.signal,
        self.userSessionStartedProperty.signal
      )
      .ksr_debounce(.seconds(5), on: AppEnvironment.current.scheduler)
      .switchMap { _ -> SignalProducer<Signal<User?, ErrorEnvelope>.Event, Never> in
        AppEnvironment.current.apiService.isAuthenticated || AppEnvironment.current.currentUser != nil
          ? AppEnvironment.current.apiService.fetchUserSelf().wrapInOptional().materialize()
          : SignalProducer(value: .value(nil))
      }

    let fetchUserSetupEvent = Signal
      .merge(
        self.applicationWillEnterForegroundProperty.signal,
        self.applicationLaunchOptionsProperty.signal.ignoreValues(),
        self.userSessionStartedProperty.signal
      )
      .switchMap { _ -> SignalProducer<Signal<UserEnvelope<GraphUserSetup>?, ErrorEnvelope>.Event, Never> in
        AppEnvironment.current.apiService.fetchGraphUserSetup().wrapInOptional().materialize()
      }

    self.fetchUserEmail = fetchUserSetupEvent.values()
      .map { user in
        guard
          let email = user?.me.email,
          let features = user?.me.enabledFeatures
        else {
          return
        }

        let ppoSettings = PPOUserSettings(
          hasAction: user?.me.ppoHasAction ?? false,
          backingActionCount: user?.me.backingActionCount ?? 0
        )

        AppEnvironment.replaceCurrentEnvironment(
          currentUserEmail: email,
          currentUserPPOSettings: ppoSettings,
          currentUserServerFeatures: features
        )

        NotificationCenter.default.post(.init(name: .ksr_userUpdated))
      }

    self.forceLogout = currentUserEvent
      .errors()
      .filter { $0.ksrCode == .AccessTokenInvalid }
      .ignoreValues()

    self.updateConfigInEnvironment = Signal.merge(
      [
        self.applicationWillEnterForegroundProperty.signal,
        self.applicationLaunchOptionsProperty.signal.ignoreValues(),
        self.userSessionEndedProperty.signal,
        self.userSessionStartedProperty.signal
      ]
    )
    .switchMap { _ -> SignalProducer<Config, Never> in
      visitorCookies().forEach(AppEnvironment.current.cookieStorage.setCookie)

      return AppEnvironment.current.apiService.fetchConfig().demoteErrors()
    }
    .map(configRetainingDebugFeatureFlags)

    let currentUserUpdatedNotification = self.currentUserUpdatedInEnvironmentProperty.signal
      .mapConst(Notification(name: .ksr_userUpdated, object: nil))

    let configUpdatedNotification = self.didUpdateConfigProperty.signal
      .skipNil()
      .mapConst(Notification(name: .ksr_configUpdated, object: nil))

    let remoteConfigClientConfiguredNotification = self.didUpdateRemoteConfigClientProperty.signal
      .mapConst(Notification(name: .ksr_remoteConfigClientConfigured, object: nil))

    let remoteConfigClientConfigurationFailedNotification = self.remoteConfigClientConfigurationFailedProperty
      .signal
      .mapConst(Notification(name: .ksr_remoteConfigClientConfigurationFailed, object: nil))

    let appEnteredBackgroundNotification = self.applicationDidEnterBackgroundProperty.signal
      .mapConst(Notification(name: .ksr_applicationDidEnterBackground, object: nil))

    self.postNotification = Signal.merge(
      currentUserUpdatedNotification,
      configUpdatedNotification,
      remoteConfigClientConfiguredNotification,
      remoteConfigClientConfigurationFailedNotification,
      appEnteredBackgroundNotification
    )

    // iCloud

    self.synchronizeUbiquitousStore = self.applicationLaunchOptionsProperty.signal.ignoreValues()

    // Push notifications

    let pushNotificationsPreviouslyAuthorized = self.applicationLaunchOptionsProperty.signal
      .flatMap { _ in AppEnvironment.current.pushRegistrationType.hasAuthorizedNotifications() }

    let pushTokenRegistrationStartedEvents = Signal.merge(
      self.didAcceptReceivingRemoteNotificationsProperty.signal,
      pushNotificationsPreviouslyAuthorized
        .filter { isPreviouslyAuthorzied in isPreviouslyAuthorzied }
        .ignoreValues()
    )
    .flatMap {
      AppEnvironment.current.pushRegistrationType.register(for: [.alert, .sound, .badge])
        .materialize()
    }

    let pushTokenRegistrationStartedValues = pushTokenRegistrationStartedEvents.values()

    self.pushTokenRegistrationStarted = pushTokenRegistrationStartedValues
      .ignoreValues()

    self.showAlert = self.showNotificationDialogProperty.signal.skipNil()
      .filter {
        if let context = $0.userInfo?.values.first as? PushNotificationDialog.Context {
          return PushNotificationDialog.canShowDialog(for: context)
        }

        return false
      }

    self.unregisterForRemoteNotifications = self.userSessionEndedProperty.signal

    self.pushTokenSuccessfullyRegistered = self.deviceTokenDataProperty.signal
      .map(deviceToken(fromData:))
      .on(value: { print("📲 [Push Registration] Push token generated: (\($0))") })
      .ksr_debounce(.seconds(5), on: AppEnvironment.current.scheduler)
      .switchMap { token in
        AppEnvironment.current.apiService.register(pushToken: token)
          .demoteErrors()
          .map { _ in token }
      }

    self.registerPushTokenInBraze = self.deviceTokenDataProperty.signal

    // MARK: - Onboarding Flow

    /// Trigger if the user hasn't authorized or denied Push Notification or AppTrackingTransparency permissions yet and hasn't seen the onboarding flow already..
    self.triggerOnboardingFlow = Signal.combineLatest(
      self.applicationLaunchOptionsProperty.signal.ignoreValues(),
      pushNotificationsPreviouslyAuthorized.filter { isFalse($0) }
    )
    .filter { _ in
      let shouldRequestAppTracking = AppEnvironment.current.appTrackingTransparency
        .shouldRequestAuthorizationStatus() == true
      let hasNotSeenOnboarding = AppEnvironment.current.userDefaults.hasSeenOnboarding == false

      return shouldRequestAppTracking && hasNotSeenOnboarding
    }
    .mapConst(())

    // Deep links. For more information, see
    // https://app.getguru.com/card/cyRdjqgi/How-iOS-Universal-Links-work

    let deepLinkFromNotification = self.remoteNotificationProperty.signal.skipNil()
      .map(PushEnvelope.decodeJSONDictionary)
      .skipNil()
      .map(navigation(fromPushEnvelope:))

    let urlFromBraze = self.brazeNotificationURLProperty.signal.skipNil()

    let deepLinkFromBraze = urlFromBraze.map(Navigation.deepLinkMatch)

    let deeplinkActivated = Signal
      .merge(
        deepLinkFromNotification,
        deepLinkFromBraze
      )
      .skipNil()

    let deepLink = deeplinkActivated

    let deepLinkOutputs = DeepLinkNavigationRouter(deepLink: deepLink)

    self.updateCurrentUserInEnvironment = Signal.merge(
      currentUserEvent.values().skipNil(),
      deepLinkOutputs.updateCurrentUserInEnvironment
    )

    self.goToMobileSafari = urlFromBraze
      .filter(shouldOpenUrlInBrowser)

    self.goToDiscovery = deepLinkOutputs.goToDiscovery
    self.goToActivity = deepLinkOutputs.goToActivity

    self.goToLoginWithIntent = Signal.merge(
      deepLinkOutputs.goToLoginWithIntent,
      self.goToLoginSignupProperty.signal.skipNil()
    )

    self.goToMessageThread = deepLinkOutputs.goToMessageThread
    self.presentViewController = deepLinkOutputs.presentViewController

    self.configureFirebase = self.applicationLaunchOptionsProperty.signal.ignoreValues()

    self.configureStatsig = self.applicationLaunchOptionsProperty.signal.ignoreValues()
      .map { _ in
        statsigSDKKey()
      }

    self.setApplicationShortcutItems = currentUserEvent
      .values()
      .switchMap(shortcutItems(forUser:))

    self.applicationDidFinishLaunchingReturnValueProperty <~ self.applicationLaunchOptionsProperty.signal
      .skipNil()
      .mapConst(true)

    self.applicationIconBadgeNumber = Signal.merge(
      self.applicationWillEnterForegroundProperty.signal,
      self.applicationLaunchOptionsProperty.signal.ignoreValues()
    )
    .flatMap { AppEnvironment.current.pushRegistrationType.hasAuthorizedNotifications() }
    .filter(isTrue)
    .mapConst(0)

    self.configureSegmentWithBraze = self.applicationLaunchOptionsProperty.signal
      .skipNil()
      .map { _ in
        AppEnvironment.current.mainBundle.isRelease
          ? Secrets.Segment.production
          : Secrets.Segment.staging
      }

    self.segmentIsEnabled = Signal.merge(
      self.didUpdateConfigProperty.signal.skipNil().ignoreValues(),
      self.configUpdatedNotificationObservedProperty.signal
    )
    .map { _ in featureSegmentIsEnabled() }
    .skipRepeats()

    /// Request AppTransparencyTracking outside of onboarding.
    self.requestATTrackingAuthorizationStatus = Signal
      .combineLatest(
        self.applicationDidFinishLaunchingReturnValueProperty.signal.ignoreValues(),
        self.applicationActiveProperty.signal
      )
      .map(second)
      .skipRepeats()
      .ksr_delay(.seconds(1), on: AppEnvironment.current.scheduler)
      .filter { applicationIsActive in
        /// Only attempt to request authorization outside of onboarding if the application is active and the user has seen the onboarding flow.
        /// We don't want to request authorzation in the onboarding flow unless they've tapped the "all tracking" CTA.
        let hasSeenOnboarding = AppEnvironment.current.userDefaults.hasSeenOnboarding == true

        return applicationIsActive && hasSeenOnboarding
      }
      .map { _ in AppEnvironment.current.appTrackingTransparency }
      .map { appTrackingTransparency in
        if
          appTrackingTransparency.advertisingIdentifier == nil &&
          appTrackingTransparency.shouldRequestAuthorizationStatus() {
          appTrackingTransparency.requestAndSetAuthorizationStatus(nil)
        }
        return ()
      }

    self.trackingAuthorizationStatus = SignalProducer
      .merge(
        self.applicationDidFinishLaunchingReturnValueProperty.signal.ignoreValues(),
        self.applicationActiveProperty.signal.ignoreValues()
      )
      .flatMap { () in
        AppEnvironment.current.appTrackingTransparency.authorizationStatus
      }
  }

  public var inputs: AppDelegateViewModelInputs { return self }
  public var outputs: AppDelegateViewModelOutputs { return self }

  fileprivate typealias ApplicationWithOptions = (
    application: UIApplication?, options: [UIApplication.LaunchOptionsKey: Any]?
  )
  fileprivate let applicationLaunchOptionsProperty = MutableProperty<ApplicationWithOptions?>(nil)
  public func applicationDidFinishLaunching(
    application: UIApplication?,
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) {
    self.applicationLaunchOptionsProperty.value = (application, launchOptions)
  }

  fileprivate let applicationWillEnterForegroundProperty = MutableProperty(())
  public func applicationWillEnterForeground() {
    self.applicationWillEnterForegroundProperty.value = ()
  }

  fileprivate let applicationActiveProperty = MutableProperty<Bool>(false)
  public func applicationActive(state: Bool) {
    self.applicationActiveProperty.value = state
  }

  fileprivate let applicationDidEnterBackgroundProperty = MutableProperty(())
  public func applicationDidEnterBackground() {
    self.applicationDidEnterBackgroundProperty.value = ()
  }

  fileprivate let applicationDidReceiveMemoryWarningProperty = MutableProperty(())
  public func applicationDidReceiveMemoryWarning() {
    self.applicationDidReceiveMemoryWarningProperty.value = ()
  }

  fileprivate let currentUserUpdatedInEnvironmentProperty = MutableProperty(())
  public func currentUserUpdatedInEnvironment() {
    self.currentUserUpdatedInEnvironmentProperty.value = ()
  }

  private let configUpdatedNotificationObservedProperty = MutableProperty(())
  public func configUpdatedNotificationObserved() {
    self.configUpdatedNotificationObservedProperty.value = ()
  }

  fileprivate let remoteNotificationProperty = MutableProperty<[AnyHashable: Any]?>(nil)
  public func didReceive(remoteNotification notification: [AnyHashable: Any]) {
    self.remoteNotificationProperty.value = notification
  }

  fileprivate let deviceTokenDataProperty = MutableProperty(Data())
  public func didRegisterForRemoteNotifications(withDeviceTokenData data: Data) {
    self.deviceTokenDataProperty.value = data
  }

  fileprivate let didAcceptReceivingRemoteNotificationsProperty = MutableProperty(())
  public func didAcceptReceivingRemoteNotifications() {
    self.didAcceptReceivingRemoteNotificationsProperty.value = ()
  }

  fileprivate let didUpdateConfigProperty = MutableProperty<Config?>(nil)
  public func didUpdateConfig(_ config: Config) {
    self.didUpdateConfigProperty.value = config
  }

  fileprivate let didUpdateRemoteConfigClientProperty = MutableProperty(())
  public func didUpdateRemoteConfigClient() {
    self.didUpdateRemoteConfigClientProperty.value = ()
  }

  private let goToLoginSignupProperty = MutableProperty<LoginIntent?>(nil)
  public func goToLoginSignup(from intent: LoginIntent) {
    self.goToLoginSignupProperty.value = intent
  }

  fileprivate let showNotificationDialogProperty = MutableProperty<Notification?>(nil)
  public func showNotificationDialog(notification: Notification) {
    self.showNotificationDialogProperty.value = notification
  }

  fileprivate let userSessionEndedProperty = MutableProperty(())
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let brazeNotificationURLProperty = MutableProperty<URL?>(nil)
  public func urlFromBrazeNotification(_ url: URL?) {
    self.brazeNotificationURLProperty.value = url
  }

  fileprivate let applicationDidFinishLaunchingReturnValueProperty = MutableProperty(true)
  public var applicationDidFinishLaunchingReturnValue: Bool {
    return self.applicationDidFinishLaunchingReturnValueProperty.value
  }

  fileprivate let remoteConfigClientConfigurationFailedProperty = MutableProperty(())
  public func remoteConfigClientConfigurationFailed() {
    self.remoteConfigClientConfigurationFailedProperty.value = ()
  }

  public let applicationIconBadgeNumber: Signal<Int, Never>
  public let configureFirebase: Signal<(), Never>
  public let configureSegmentWithBraze: Signal<String, Never>
  public let configureStatsig: Signal<StatsigClientSDKKey, Never>
  public let forceLogout: Signal<(), Never>
  private let fetchUserEmail: Signal<(), Never>
  public let goToActivity: Signal<(), Never>
  public let goToDiscovery: Signal<DiscoveryParams?, Never>
  public let goToLoginWithIntent: Signal<LoginIntent, Never>
  public let goToMessageThread: Signal<MessageThread, Never>
  public let goToMobileSafari: Signal<URL, Never>
  public let postNotification: Signal<Notification, Never>
  public let presentViewController: Signal<UIViewController, Never>
  public let pushTokenRegistrationStarted: Signal<(), Never>
  public let pushTokenSuccessfullyRegistered: Signal<String, Never>
  public let registerPushTokenInBraze: Signal<Data, Never>
  public let requestATTrackingAuthorizationStatus: Signal<Void, Never>
  public let segmentIsEnabled: Signal<Bool, Never>
  public let setApplicationShortcutItems: Signal<[ShortcutItem], Never>
  public let showAlert: Signal<Notification, Never>
  public let synchronizeUbiquitousStore: Signal<(), Never>
  public let trackingAuthorizationStatus: SignalProducer<AppTrackingAuthorization, Never>
  public let triggerOnboardingFlow: Signal<(), Never>
  public let unregisterForRemoteNotifications: Signal<(), Never>
  public let updateCurrentUserInEnvironment: Signal<User, Never>
  public let updateConfigInEnvironment: Signal<Config, Never>
}

private func deviceToken(fromData data: Data) -> String {
  return data
    .map { String(format: "%02.2hhx", $0 as CVarArg) }
    .joined()
}

private func navigation(fromPushEnvelope envelope: PushEnvelope) -> Navigation? {
  if let activity = envelope.activity {
    switch activity.category {
    case .backing:
      guard let projectId = activity.projectId else { return nil }
      return .project(.id(projectId), .root, refInfo: RefInfo(.push))
    case .failure, .launch, .success, .cancellation, .suspension:
      guard let projectId = activity.projectId else { return nil }
      return .project(.id(projectId), .root, refInfo: RefInfo(.push))

    case .update:
      guard let projectId = activity.projectId, let updateId = activity.updateId else { return nil }
      return .project(.id(projectId), .update(updateId, .root), refInfo: RefInfo(.push))

    case .commentPost:
      guard let projectId = activity.projectId, let updateId = activity.updateId else { return nil }

      if let commentId = activity.commentId {
        return .project(
          .id(projectId),
          .update(updateId, .commentThread(commentId, activity.replyId)),
          refInfo: RefInfo(.push)
        )
      }
      return .project(.id(projectId), .update(updateId, .comments), refInfo: RefInfo(.push))

    case .commentProject:
      guard let projectId = activity.projectId else { return nil }

      if let commentId = activity.commentId {
        return .project(.id(projectId), .commentThread(commentId, activity.replyId), refInfo: RefInfo(.push))
      }
      return .project(.id(projectId), .comments, refInfo: RefInfo(.push))

    case .follow:
      return .tab(.activity)

    case .funding, .shipped, .unknown, .watch:
      return nil
    }
  }

  if let order = envelope.order {
    let path = order.pledgeManagerPath
    let url = AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString + path
    return .project(.id(order.projectId), .pledgeManagerWebview(url), refInfo: RefInfo(.push))
  }

  if let project = envelope.project {
    return .project(.id(project.id), .root, refInfo: RefInfo(.push))
  }

  if let message = envelope.message {
    return .messages(messageThreadId: message.messageThreadId)
  }

  if let survey = envelope.survey {
    let path = survey.urls.web.survey
    let url = AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString + path
    return .project(.id(survey.projectId), .pledgeManagerWebview(url), refInfo: RefInfo(.push))
  }

  if let update = envelope.update {
    return .project(.id(update.projectId), .update(update.id, .root), refInfo: RefInfo(.push))
  }

  if let erroredPledge = envelope.erroredPledge {
    return .project(.id(erroredPledge.projectId), .pledge(.manage), refInfo: RefInfo(.push))
  }

  return nil
}

// Figures out which shortcut items to show to a user.
private func shortcutItems(forUser user: User?) -> SignalProducer<[ShortcutItem], Never> {
  guard let user = user else {
    return SignalProducer(value: shortcutItems(isProjectMember: false, hasRecommendations: false))
  }

  let recommendationParams = .defaults
    |> DiscoveryParams.lens.recommended .~ true
    |> DiscoveryParams.lens.state .~ .live
    |> DiscoveryParams.lens.perPage .~ 1

  let recommendationsCount = AppEnvironment.current.apiService.fetchDiscovery(params: recommendationParams)
    .map { $0.stats.count }
    .flatMapError { _ in SignalProducer<Int, Never>(value: 0) }

  return recommendationsCount
    .map { recommendationsCount in
      shortcutItems(
        isProjectMember: (user.stats.memberProjectsCount ?? 0) > 0,
        hasRecommendations: recommendationsCount > 0
      )
    }
    .demoteErrors()
}

// Figures out which shortcut items to show to a user based on whether they are a project member and/or
// has recommendations.
private func shortcutItems(isProjectMember _: Bool, hasRecommendations: Bool)
  -> [ShortcutItem] {
  var items: [ShortcutItem] = []

  if hasRecommendations {
    items.append(.recommendedForYou)
  }

  items.append(.projectsWeLove)

  if items.count < 4 {
    items.append(.search)
  }

  return items
}

private func dictionary(fromUrlComponents urlComponents: URLComponents) -> [String: String] {
  let queryItems = urlComponents.queryItems ?? []
  return [String: String?].keyValuePairs(queryItems.map { ($0.name, $0.value) }).compact()
}

extension ShortcutItem {
  public var applicationShortcutItem: UIApplicationShortcutItem {
    switch self {
    case .projectsWeLove:
      return .init(
        type: self.typeString,
        localizedTitle: Strings.Projects_We_Love(),
        localizedSubtitle: nil,
        icon: UIApplicationShortcutIcon(templateImageName: "shortcut-icon-k"),
        userInfo: nil
      )
    case .recommendedForYou:
      return .init(
        type: self.typeString,
        localizedTitle: Strings.Recommended(),
        localizedSubtitle: nil,
        icon: UIApplicationShortcutIcon(templateImageName: "shortcut-icon-star"),
        userInfo: nil
      )
    case .search:
      return .init(
        type: self.typeString,
        localizedTitle: Strings.tabbar_search(),
        localizedSubtitle: nil,
        icon: UIApplicationShortcutIcon(templateImageName: "shortcut-icon-search"),
        userInfo: nil
      )
    }
  }
}

private func visitorCookies() -> [HTTPCookie] {
  let uuidString = (AppEnvironment.current.device.identifierForVendor ?? UUID()).uuidString

  return [HTTPCookie?].init(
    arrayLiteral:
    HTTPCookie(
      properties: [
        .name: "vis",
        .value: uuidString,
        .domain: AppEnvironment.current.apiService.serverConfig.webBaseUrl.host as Any,
        .path: "/",
        .version: 0,
        .expires: Date.distantFuture,
        .secure: true
      ]
    ),
    HTTPCookie(
      properties: [
        .name: "vis",
        .value: uuidString,
        .domain: AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host as Any,
        .path: "/",
        .version: 0,
        .expires: Date.distantFuture,
        .secure: true
      ]
    )
  )
  .compact()
}

private func configRetainingDebugFeatureFlags(_ config: Config) -> Config {
  guard AppEnvironment.current.mainBundle.isRelease == false else { return config }

  let currentFeatures = config.features
  let currentFeatureKeys = Set(currentFeatures.keys)

  let storedFeatures = (AppEnvironment.current.config?.features ?? [:])
    .filter { key, _ in currentFeatureKeys.contains(key) }

  return config |> Config.lens.features .~ currentFeatures.withAllValuesFrom(storedFeatures)
}

private func statsigSDKKey() -> StatsigClientSDKKey {
  let mainBundle = AppEnvironment.current.mainBundle

  if mainBundle.isRelease {
    return .productionTier(Secrets.Statsig.production)
  } else if mainBundle.isBeta {
    return .stagingTier(Secrets.Statsig.staging)
  } else if mainBundle.isDebug {
    return .developmentTier(Secrets.Statsig.development)
  }

  return .stagingTier(Secrets.Statsig.sandbox)
}
