import Argo
import KsApi
import Library
import Prelude
import ReactiveSwift
import UserNotifications

public struct AppCenterConfigData: Equatable {
  public let appSecret: String
  public let userId: String
  public let userName: String
}

public enum NotificationAuthorizationStatus {
  case authorized
  case denied
  case notDetermined
  case provisional
}

public protocol AppDelegateViewModelInputs {
  /// Call when the application is handed off to.
  func applicationContinueUserActivity(_ userActivity: NSUserActivity) -> Bool

  /// Call when the application finishes launching.
  func applicationDidFinishLaunching(
    application: UIApplication?, launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  )

  /// Call when the application will enter foreground.
  func applicationWillEnterForeground()

  /// Call when the application enters background.
  func applicationDidEnterBackground()

  /// Call when the aplication receives memory warning from the system.
  func applicationDidReceiveMemoryWarning()

  /// Call to open a url that was sent to the app
  func applicationOpenUrl(
    application: UIApplication?,
    url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool

  /// Call when the application receives a request to perform a shortcut action.
  func applicationPerformActionForShortcutItem(_ item: UIApplicationShortcutItem)

  /// Call when the app has crashed
  func crashManagerDidFinishSendingCrashReport()

  /// Call after having invoked AppEnvironemt.updateCurrentUser with a fresh user.
  func currentUserUpdatedInEnvironment()

  /// Call when the user taps "OK" from the contextual alert.
  func didAcceptReceivingRemoteNotifications()

  /// Call with the result of evaluating Qualtrics Targeting Logic and current Qualtrics.Properties
  func didEvaluateQualtricsTargetingLogic(
    with result: QualtricsResultType, properties: QualtricsPropertiesType
  )

  /// Call when the app delegate receives a remote notification.
  func didReceive(remoteNotification notification: [AnyHashable: Any])

  /// Call when the app delegate gets notice of a successful notification registration.
  func didRegisterForRemoteNotifications(withDeviceTokenData data: Data)

  /// Call when the config has been updated the AppEnvironment
  func didUpdateConfig(_ config: Config)

  /// Call when the Optimizely client has been updated in the AppEnvironment
  func didUpdateOptimizelyClient(_ client: OptimizelyClientType)

  /// Call when the redirect URL has been found, see `findRedirectUrl` for more information.
  func foundRedirectUrl(_ url: URL)

  /// Call when Optimizely has been configured with the given result
  func optimizelyConfigured(with result: OptimizelyResultType) -> Error?

  /// Call when Optimizely configuration has failed
  func optimizelyClientConfigurationFailed()

  /// Call with the result from initializing Qualtrics
  func qualtricsInitialized(with result: QualtricsResultType)

  /// Call when the contextual PushNotification dialog should be presented.
  func showNotificationDialog(notification: Notification)

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

  /// Emits an app secret that should be used to configure AppCenter.
  var configureAppCenterWithData: Signal<AppCenterConfigData, Never> { get }

  /// Emits when the application should configure Fabric
  var configureFabric: Signal<(), Never> { get }

  /// Emits when the application should configure Optimizely
  var configureOptimizely: Signal<(String, OptimizelyLogLevelType, TimeInterval), Never> { get }

  /// Emits when the application should configure Qualtrics
  var configureQualtrics: Signal<QualtricsConfigData, Never> { get }

  /// Return this value in the delegate method.
  var continueUserActivityReturnValue: MutableProperty<Bool> { get }

  /// Emits when we should display the Qualtrics survey.
  var displayQualtricsSurvey: Signal<(), Never> { get }

  /// Emits when we should ask Qualtrics to evaluate its targeting logic.
  var evaluateQualtricsTargetingLogic: Signal<(), Never> { get }

  /// Emits when the view needs to figure out the redirect URL for the emitted URL.
  var findRedirectUrl: Signal<URL, Never> { get }

  /// Emits when opening the app with an invalid access token.
  var forceLogout: Signal<(), Never> { get }

  /// Emits when the root view controller should navigate to activity.
  var goToActivity: Signal<(), Never> { get }

  /// Emits when the root view controller should navigate to the onboarding flow
  var goToCategoryPersonalizationOnboarding: Signal<Void, Never> { get }

  /// Emits when application should navigate to the creator's message thread
  var goToCreatorMessageThread: Signal<(Param, MessageThread), Never> { get }

  /// Emits when the root view controller should navigate to the creator dashboard.
  var goToDashboard: Signal<Param?, Never> { get }

  /// Emits when the root view controller should navigate to the creator dashboard.
  var goToDiscovery: Signal<DiscoveryParams?, Never> { get }

  /// Emits when the root view controller should present the Landing Page for new users.
  var goToLandingPage: Signal<(), Never> { get }

  /// Emits when the root view controller should present the login modal.
  var goToLoginWithIntent: Signal<LoginIntent, Never> { get }

  /// Emits a message thread when we should navigate to it.
  var goToMessageThread: Signal<MessageThread, Never> { get }

  /// Emits when the root view controller should navigate to the user's profile.
  var goToProfile: Signal<(), Never> { get }

  /// Emits when should navigate to the project activities view
  var goToProjectActivities: Signal<Param, Never> { get }

  /// Emits a URL when we should open it in the safari browser.
  var goToMobileSafari: Signal<URL, Never> { get }

  /// Emits when the root view controller should navigate to search.
  var goToSearch: Signal<(), Never> { get }

  /// Emits an Notification that should be immediately posted.
  var postNotification: Signal<Notification, Never> { get }

  /// Emits when a view controller should be presented.
  var presentViewController: Signal<UIViewController, Never> { get }

  /// Emits when the push token registration begins.
  var pushTokenRegistrationStarted: Signal<(), Never> { get }

  /// Emits the push token that has been successfully registered on the server.
  var pushTokenSuccessfullyRegistered: Signal<String, Never> { get }

  /// Emits an array of short cut items to put into the shared application.
  var setApplicationShortcutItems: Signal<[ShortcutItem], Never> { get }

  /// Emits when an alert should be shown.
  var showAlert: Signal<Notification, Never> { get }

  /// Emits to synchronize iCloud on app launch.
  var synchronizeUbiquitousStore: Signal<(), Never> { get }

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

    self.updateCurrentUserInEnvironment = currentUserEvent
      .values()
      .skipNil()

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

    let currentUserUpdatedNotification = self.currentUserUpdatedInEnvironmentProperty.signal
      .mapConst(Notification(name: .ksr_userUpdated, object: nil))

    let configUpdatedNotification = self.didUpdateConfigProperty.signal
      .skipNil()
      .mapConst(Notification(name: .ksr_configUpdated, object: nil))

    let optimizelyClientConfiguredNotification = self.didUpdateOptimizelyClientProperty.signal
      .mapConst(Notification(name: .ksr_optimizelyClientConfigured, object: nil))

    let optimizelyClientConfigurationFailedNotification = self.optimizelyClientConfigurationFailedProperty
      .signal
      .mapConst(Notification(name: .ksr_optimizelyClientConfigurationFailed, object: nil))

    self.postNotification = Signal.merge(
      currentUserUpdatedNotification,
      configUpdatedNotification,
      optimizelyClientConfiguredNotification,
      optimizelyClientConfigurationFailedNotification
    )

    let openUrl = self.applicationOpenUrlProperty.signal.skipNil()

    // iCloud

    self.synchronizeUbiquitousStore = self.applicationLaunchOptionsProperty.signal.ignoreValues()

    // Push notifications

    let pushNotificationsPreviouslyAuthorized = self.applicationLaunchOptionsProperty.signal
      .flatMap { _ in AppEnvironment.current.pushRegistrationType.hasAuthorizedNotifications() }

    let pushTokenRegistrationStartedEvents = Signal.merge(
      self.didAcceptReceivingRemoteNotificationsProperty.signal,
      pushNotificationsPreviouslyAuthorized.filter(isTrue).ignoreValues()
    )
    .flatMap {
      AppEnvironment.current.pushRegistrationType.register(for: [.alert, .badge])
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

    // Onboarding

    self.goToCategoryPersonalizationOnboarding = Signal.combineLatest(
      self.applicationLaunchOptionsProperty.signal.ignoreValues(),
      self.didUpdateOptimizelyClientProperty.signal.skipNil().ignoreValues()
    ).ignoreValues()
      .filter(shouldSeeCategoryPersonalization)

    // Deep links

    let deepLinkFromNotification = self.remoteNotificationProperty.signal.skipNil()
      .map(decode)
      .map { $0.value }
      .skipNil()
      .map(navigation(fromPushEnvelope:))

    let continueUserActivity = self.applicationContinueUserActivityProperty.signal.skipNil()

    let continueUserActivityWithNavigation = continueUserActivity
      .filter { $0.activityType == NSUserActivityTypeBrowsingWeb }
      .map { activity in (activity, activity.webpageURL.flatMap(Navigation.match)) }

    self.continueUserActivityReturnValue <~ continueUserActivityWithNavigation.map(second >>> isNotNil)

    let deepLinkUrl = Signal
      .merge(
        openUrl.map { $0.url },
        self.foundRedirectUrlProperty.signal.skipNil(),
        continueUserActivity
          .filter { $0.activityType == NSUserActivityTypeBrowsingWeb }
          .map { $0.webpageURL }
          .skipNil()
      )

    let deepLinkFromUrl = deepLinkUrl.map(Navigation.match)

    let performShortcutItem = Signal.merge(
      self.performActionForShortcutItemProperty.signal.skipNil(),
      self.applicationLaunchOptionsProperty.signal
        .map { $0?.options?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem }
        .skipNil()
    )
    .map { ShortcutItem(typeString: $0.type) }
    .skipNil()

    let deepLinkFromShortcut = performShortcutItem
      .switchMap(navigation(fromShortcutItem:))

    let deeplinkActivated = Signal
      .merge(
        deepLinkFromUrl,
        deepLinkFromNotification,
        deepLinkFromShortcut
      )
      .skipNil()

    self.goToLandingPage = self.applicationLaunchOptionsProperty.signal.ignoreValues()
      .takeWhen(self.didUpdateOptimizelyClientProperty.signal.ignoreValues())
      .filter(shouldGoToLandingPage)

    let deepLink = deeplinkActivated
      .filter { _ in shouldGoToLandingPage() == false && shouldSeeCategoryPersonalization() == false }
      .take(until: self.goToLandingPage)

    self.findRedirectUrl = deepLinkUrl
      .filter { Navigation.match($0) == .emailClick }

    self.goToDiscovery = deepLink
      .map { link -> [String: String]?? in
        guard case let .tab(.discovery(rawParams)) = link else { return nil }
        return .some(rawParams)
      }
      .skipNil()
      .switchMap { rawParams -> SignalProducer<DiscoveryParams?, Never> in
        guard
          let rawParams = rawParams,
          let params = DiscoveryParams.decode(.init(rawParams)).value
        else { return .init(value: nil) }

        guard
          let rawCategoryParam = rawParams["category_id"],
          let categoryParam = Param.decode(.string(rawCategoryParam)).value
        else { return .init(value: params) }
        // We will replace `fetchGraph(query: rootCategoriesQuery)` by a call to get a category by ID
        return AppEnvironment.current.apiService.fetchGraphCategories(query: rootCategoriesQuery)
          .map { $0.rootCategories.filter { $0.name.lowercased() == categoryParam.slug } }
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
          .map { params |> DiscoveryParams.lens.category .~ $0.first }
      }

    let projectLinkValues = deepLink
      .map { link -> (Param, Navigation.Project, RefTag?)? in
        guard case let .project(param, subpage, refTag) = link else { return nil }
        return (param, subpage, refTag)
      }
      .skipNil()
      .switchMap { param, subpage, refTag in
        AppEnvironment.current.apiService.fetchProject(param: param)
          .demoteErrors()
          .observeForUI()
          .map { project -> (Project, Navigation.Project, [UIViewController], RefTag?) in
            (
              project, subpage,
              [ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: refTag)],
              refTag
            )
          }
      }

    let projectLink = projectLinkValues
      .filter { project, _, _, _ in project.prelaunchActivated != true }

    let projectPreviewLink = projectLinkValues
      .filter { project, _, _, _ in project.prelaunchActivated == true }

    let fixErroredPledgeLinkAndIsLoggedIn = projectLink
      .filter { _, subpage, _, _ in subpage == .pledge(.manage) }
      .map { project, _, vcs, _ in
        (project, vcs, AppEnvironment.current.currentUser != nil)
      }

    let fixErroredPledgeLink = fixErroredPledgeLinkAndIsLoggedIn
      .filter(third >>> isTrue)
      .map { project, vcs, _ -> [UIViewController]? in
        guard let backingId = project.personalization.backing?.id else { return nil }
        let vc = ManagePledgeViewController.instantiate()
        let params: ManagePledgeViewParamConfigData = (.id(project.id), .id(backingId))
        vc.configureWith(params: params)
        return vcs + [vc]
      }
      .skipNil()
      .map { vcs -> RewardPledgeNavigationController in
        let nav = RewardPledgeNavigationController(nibName: nil, bundle: nil)
        nav.viewControllers = vcs
        return nav
      }

    self.goToActivity = deepLink
      .filter { $0 == .tab(.activity) }
      .ignoreValues()

    self.goToSearch = deepLink
      .filter { $0 == .tab(.search) }
      .ignoreValues()

    let goToLogin = deepLink
      .filter { $0 == .tab(.login) }
      .ignoreValues()

    self.goToLoginWithIntent = Signal.merge(
      fixErroredPledgeLinkAndIsLoggedIn.filter(third >>> isFalse).mapConst(.erroredPledge),
      goToLogin.mapConst(.generic)
    )

    self.goToCreatorMessageThread = deepLink
      .map { navigation -> (Param, Int)? in
        guard case let .creatorMessages(projectId, messageThreadId) = navigation else { return nil }
        return .some((projectId, messageThreadId: messageThreadId))
      }
      .skipNil()
      .switchMap { projectId, messageThreadId in
        AppEnvironment.current.apiService.fetchMessageThread(messageThreadId: messageThreadId)
          .demoteErrors()
          .map { (projectId, $0.messageThread) }
      }

    self.goToMessageThread = deepLink
      .map { navigation -> Int? in
        guard case let .messages(messageThreadId) = navigation else { return nil }
        return .some(messageThreadId)
      }
      .skipNil()
      .switchMap {
        AppEnvironment.current.apiService.fetchMessageThread(messageThreadId: $0)
          .demoteErrors()
          .map { $0.messageThread }
      }

    self.goToProjectActivities = deepLink
      .map { navigation -> Param? in
        guard case let .projectActivity(projectId) = navigation else { return nil }
        return .some(projectId)
      }
      .skipNil()

    self.goToProfile = deepLink
      .filter { $0 == .tab(.me) }
      .ignoreValues()

    let resolvedRedirectUrl = deepLinkUrl
      .filter { Navigation.deepLinkMatch($0) == nil }

    self.goToMobileSafari = Signal.merge(
      resolvedRedirectUrl,
      Signal.zip(deepLinkUrl, projectPreviewLink).map(first)
    )

    self.goToDashboard = deepLink
      .map { link -> Param?? in
        guard case let .tab(.dashboard(param)) = link else { return nil }
        return .some(param)
      }
      .skipNil()

    let projectRootLink = projectLink
      .filter { _, subpage, _, _ in subpage == .root }
      .map { _, _, vcs, _ in vcs }

    let projectCommentsLink = projectLink
      .filter { _, subpage, _, _ in subpage == .comments }
      .map { project, _, vcs, _ in
        vcs + [CommentsViewController.configuredWith(project: project, update: nil)]
      }

    let surveyResponseLink = deepLink
      .map { link -> Int? in
        if case let .user(_, .survey(surveyResponseId)) = link { return surveyResponseId }
        if case let .project(_, .survey(surveyResponseId), _) = link { return surveyResponseId }
        return nil
      }
      .skipNil()
      .switchMap { surveyResponseId in
        AppEnvironment.current.apiService.fetchSurveyResponse(surveyResponseId: surveyResponseId)
          .demoteErrors()
          .observeForUI()
          .map { surveyResponse -> [UIViewController] in
            [SurveyResponseViewController.configuredWith(surveyResponse: surveyResponse)]
          }
      }

    let campaignFaqLink = projectLink
      .filter { _, subpage, _, _ in subpage == .faqs }
      .map { project, _, vcs, refTag in
        vcs + [ProjectDescriptionViewController.configuredWith(value: (project, refTag))]
      }

    let updatesLink = projectLink
      .filter { _, subpage, _, _ in subpage == .updates }
      .map { project, _, vcs, _ in vcs + [ProjectUpdatesViewController.configuredWith(project: project)] }

    let updateLink = projectLink
      .map { project, subpage, vcs, _ -> (Project, Int, Navigation.Project.Update, [UIViewController])? in
        guard case let .update(id, updateSubpage) = subpage else { return nil }
        return (project, id, updateSubpage, vcs)
      }
      .skipNil()
      .switchMap { project, id, updateSubpage, vcs in
        AppEnvironment.current.apiService.fetchUpdate(updateId: id, projectParam: .id(project.id))
          .demoteErrors()
          .observeForUI()
          .map { update -> (Project, Update, Navigation.Project.Update, [UIViewController]) in
            (
              project,
              update,
              updateSubpage,
              vcs + [
                UpdateViewController.configuredWith(
                  project: project,
                  update: update,
                  context: .deepLink
                )
              ]
            )
          }
      }

    let updateRootLink = updateLink
      .filter { _, _, subpage, _ in subpage == .root }
      .map { _, _, _, vcs in vcs }

    let updateCommentsLink = updateLink
      .observeForUI()
      .map { _, update, subpage, vcs -> [UIViewController]? in
        guard case .comments = subpage else { return nil }
        return vcs + [CommentsViewController.configuredWith(update: update)]
      }
      .skipNil()

    let viewControllersContainedInNavigationController = Signal
      .merge(
        projectRootLink,
        projectCommentsLink,
        surveyResponseLink,
        updatesLink,
        updateRootLink,
        updateCommentsLink,
        campaignFaqLink
      )
      .map { UINavigationController() |> UINavigationController.lens.viewControllers .~ $0 }

    self.presentViewController = Signal.merge(
      viewControllersContainedInNavigationController.map { $0 as UIViewController },
      fixErroredPledgeLink.map { $0 as UIViewController }
    )

    self.configureFabric = self.applicationLaunchOptionsProperty.signal.ignoreValues()

    self.configureOptimizely = self.applicationLaunchOptionsProperty.signal
      .map { _ in AppEnvironment.current }
      .map(optimizelyData(for:))

    self.configureAppCenterWithData = Signal.merge(
      self.applicationLaunchOptionsProperty.signal.ignoreValues(),
      self.userSessionStartedProperty.signal,
      self.userSessionEndedProperty.signal
    )
    .filter { !AppEnvironment.current.mainBundle.isDebug && !AppEnvironment.current.mainBundle.isRelease }
    .map { _ -> AppCenterConfigData? in
      guard let appCenterAppSecret = AppEnvironment.current.mainBundle.appCenterAppSecret else { return nil }

      return AppCenterConfigData(
        appSecret: appCenterAppSecret,
        userId: (AppEnvironment.current.currentUser?.id).map(String.init) ?? "0",
        userName: AppEnvironment.current.currentUser?.name ?? "anonymous"
      )
    }
    .skipNil()

    self.setApplicationShortcutItems = currentUserEvent
      .values()
      .switchMap(shortcutItems(forUser:))

    self.applicationDidFinishLaunchingReturnValueProperty <~ self.applicationLaunchOptionsProperty.signal
      .skipNil()
      .map { _, options in options?[UIApplication.LaunchOptionsKey.shortcutItem] == nil }

    // Koala

    Signal.combineLatest(
      pushTokenRegistrationStartedValues,
      pushNotificationsPreviouslyAuthorized
    )
    .filter { _, previouslyAuthorized in !previouslyAuthorized }
    .map { isGranted, _ in isGranted }
    .take(first: 1)
    .observeValues { isGranted in
      if isGranted {
        AppEnvironment.current.koala.trackPushPermissionOptIn()
      } else {
        AppEnvironment.current.koala.trackPushPermissionOptOut()
      }
    }

    Signal.merge(
      self.applicationLaunchOptionsProperty.signal.ignoreValues(),
      self.applicationWillEnterForegroundProperty.signal
    )
    .observeValues { AppEnvironment.current.koala.trackAppOpen() }

    self.applicationDidReceiveMemoryWarningProperty.signal
      .observeValues { AppEnvironment.current.koala.trackMemoryWarning() }

    self.crashManagerDidFinishSendingCrashReportProperty.signal
      .observeValues { AppEnvironment.current.koala.trackCrashedApp() }

    Signal.combineLatest(
      performShortcutItem.enumerated(),
      self.setApplicationShortcutItems
    )
    .skipRepeats { lhs, rhs in lhs.0.idx == rhs.0.idx }
    .map { idxAndShortcutItem, availableShortcutItems in
      (idxAndShortcutItem.value, availableShortcutItems)
    }
    .observeValues {
      AppEnvironment.current.koala.trackPerformedShortcutItem($0, availableShortcutItems: $1)
    }

    openUrl
      .map { URLComponents(url: $0.url, resolvingAgainstBaseURL: false) }
      .skipNil()
      .map(dictionary(fromUrlComponents:))
      .filter { $0["app_banner"] == "1" }
      .observeValues { AppEnvironment.current.koala.trackOpenedAppBanner($0) }

    continueUserActivityWithNavigation
      .filter(second >>> isNotNil)
      .map(first)
      .observeValues { AppEnvironment.current.koala.trackUserActivity($0) }

    deepLinkFromNotification
      .observeValues { _ in AppEnvironment.current.koala.trackNotificationOpened() }

    self.applicationIconBadgeNumber = Signal.merge(
      self.applicationWillEnterForegroundProperty.signal,
      self.applicationLaunchOptionsProperty.signal.ignoreValues()
    )
    .flatMap { AppEnvironment.current.pushRegistrationType.hasAuthorizedNotifications() }
    .filter(isTrue)
    .mapConst(0)

    self.optimizelyConfigurationReturnValue <~ self.optimizelyConfiguredWithResultProperty.signal
      .skipNil()
      .map { $0.hasError }

    self.configureQualtrics = Signal.zip(
      self.applicationLaunchOptionsProperty.signal,
      self.didUpdateConfigProperty.signal
    )
    .filter { _ in featureQualtricsIsEnabled() }
    .ignoreValues()
    .map(qualtricsConfigData)

    self.evaluateQualtricsTargetingLogic = self.qualtricsInitializedWithResultProperty.signal
      .skipNil()
      .filter { $0.passed() }
      .ksr_delay(.seconds(2), on: AppEnvironment.current.scheduler)
      .ignoreValues()

    self.displayQualtricsSurvey = self.didEvaluateQualtricsTargetingLogicWithResultProperty.signal
      .skipNil()
      .on(value: { _, properties in properties.setNumber(number: 0, for: "first_app_session") })
      .filter { result, _ in result.passed() }
      .ignoreValues()
  }

  public var inputs: AppDelegateViewModelInputs { return self }
  public var outputs: AppDelegateViewModelOutputs { return self }

  fileprivate let applicationContinueUserActivityProperty = MutableProperty<NSUserActivity?>(nil)
  public func applicationContinueUserActivity(_ userActivity: NSUserActivity) -> Bool {
    self.applicationContinueUserActivityProperty.value = userActivity
    return self.continueUserActivityReturnValue.value
  }

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

  fileprivate let applicationDidEnterBackgroundProperty = MutableProperty(())
  public func applicationDidEnterBackground() {
    self.applicationDidEnterBackgroundProperty.value = ()
  }

  fileprivate let applicationDidReceiveMemoryWarningProperty = MutableProperty(())
  public func applicationDidReceiveMemoryWarning() {
    self.applicationDidReceiveMemoryWarningProperty.value = ()
  }

  fileprivate let performActionForShortcutItemProperty = MutableProperty<UIApplicationShortcutItem?>(nil)
  public func applicationPerformActionForShortcutItem(_ item: UIApplicationShortcutItem) {
    self.performActionForShortcutItemProperty.value = item
  }

  fileprivate let currentUserUpdatedInEnvironmentProperty = MutableProperty(())
  public func currentUserUpdatedInEnvironment() {
    self.currentUserUpdatedInEnvironmentProperty.value = ()
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

  fileprivate let didEvaluateQualtricsTargetingLogicWithResultProperty
    = MutableProperty<(QualtricsResultType, QualtricsPropertiesType)?>(nil)
  public func didEvaluateQualtricsTargetingLogic(
    with result: QualtricsResultType,
    properties: QualtricsPropertiesType
  ) {
    self.didEvaluateQualtricsTargetingLogicWithResultProperty.value = (result, properties)
  }

  fileprivate let didUpdateConfigProperty = MutableProperty<Config?>(nil)
  public func didUpdateConfig(_ config: Config) {
    self.didUpdateConfigProperty.value = config
  }

  fileprivate let didUpdateOptimizelyClientProperty = MutableProperty<OptimizelyClientType?>(nil)
  public func didUpdateOptimizelyClient(_ client: OptimizelyClientType) {
    self.didUpdateOptimizelyClientProperty.value = client
  }

  private let foundRedirectUrlProperty = MutableProperty<URL?>(nil)
  public func foundRedirectUrl(_ url: URL) {
    self.foundRedirectUrlProperty.value = url
  }

  fileprivate let crashManagerDidFinishSendingCrashReportProperty = MutableProperty(())
  public func crashManagerDidFinishSendingCrashReport() {
    self.crashManagerDidFinishSendingCrashReportProperty.value = ()
  }

  fileprivate typealias ApplicationOpenUrl = (
    application: UIApplication?,
    url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  )
  fileprivate let applicationOpenUrlProperty = MutableProperty<ApplicationOpenUrl?>(nil)
  public func applicationOpenUrl(
    application: UIApplication?,
    url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool {
    self.applicationOpenUrlProperty.value = (application, url, options)
    return true
  }

  fileprivate let qualtricsInitializedWithResultProperty = MutableProperty<QualtricsResultType?>(nil)
  public func qualtricsInitialized(with result: QualtricsResultType) {
    self.qualtricsInitializedWithResultProperty.value = result
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

  fileprivate let applicationDidFinishLaunchingReturnValueProperty = MutableProperty(true)
  public var applicationDidFinishLaunchingReturnValue: Bool {
    return self.applicationDidFinishLaunchingReturnValueProperty.value
  }

  private let optimizelyConfigurationReturnValue = MutableProperty<Error?>(nil)
  fileprivate let optimizelyConfiguredWithResultProperty = MutableProperty<OptimizelyResultType?>(nil)
  public func optimizelyConfigured(with result: OptimizelyResultType) -> Error? {
    self.optimizelyConfiguredWithResultProperty.value = result

    return self.optimizelyConfigurationReturnValue.value
  }

  fileprivate let optimizelyClientConfigurationFailedProperty = MutableProperty(())
  public func optimizelyClientConfigurationFailed() {
    self.optimizelyClientConfigurationFailedProperty.value = ()
  }

  public let applicationIconBadgeNumber: Signal<Int, Never>
  public let configureAppCenterWithData: Signal<AppCenterConfigData, Never>
  public let configureFabric: Signal<(), Never>
  public let configureOptimizely: Signal<(String, OptimizelyLogLevelType, TimeInterval), Never>
  public let configureQualtrics: Signal<QualtricsConfigData, Never>
  public let continueUserActivityReturnValue = MutableProperty(false)
  public let displayQualtricsSurvey: Signal<(), Never>
  public let evaluateQualtricsTargetingLogic: Signal<(), Never>
  public let findRedirectUrl: Signal<URL, Never>
  public let forceLogout: Signal<(), Never>
  public let goToActivity: Signal<(), Never>
  public let goToCategoryPersonalizationOnboarding: Signal<Void, Never>
  public let goToCreatorMessageThread: Signal<(Param, MessageThread), Never>
  public let goToDashboard: Signal<Param?, Never>
  public let goToDiscovery: Signal<DiscoveryParams?, Never>
  public let goToLandingPage: Signal<(), Never>
  public let goToLoginWithIntent: Signal<LoginIntent, Never>
  public let goToMessageThread: Signal<MessageThread, Never>
  public let goToProfile: Signal<(), Never>
  public let goToProjectActivities: Signal<Param, Never>
  public let goToMobileSafari: Signal<URL, Never>
  public let goToSearch: Signal<(), Never>
  public let postNotification: Signal<Notification, Never>
  public let presentViewController: Signal<UIViewController, Never>
  public let pushTokenRegistrationStarted: Signal<(), Never>
  public let pushTokenSuccessfullyRegistered: Signal<String, Never>
  public let setApplicationShortcutItems: Signal<[ShortcutItem], Never>
  public let showAlert: Signal<Notification, Never>
  public let synchronizeUbiquitousStore: Signal<(), Never>
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
      if envelope.forCreator == true {
        return .projectActivity(.id(projectId))
      }
      return .project(.id(projectId), .root, refTag: .push)
    case .failure, .launch, .success, .cancellation, .suspension:
      guard let projectId = activity.projectId else { return nil }
      if envelope.forCreator == .some(true) {
        return .tab(.dashboard(project: .id(projectId)))
      }
      return .project(.id(projectId), .root, refTag: .push)

    case .update:
      guard let projectId = activity.projectId, let updateId = activity.updateId else { return nil }
      return .project(.id(projectId), .update(updateId, .root), refTag: .push)

    case .commentPost:
      guard let projectId = activity.projectId, let updateId = activity.updateId else { return nil }
      return .project(.id(projectId), .update(updateId, .comments), refTag: .push)

    case .commentProject:
      guard let projectId = activity.projectId else { return nil }
      return .project(.id(projectId), .comments, refTag: .push)

    case .backingAmount, .backingCanceled, .backingDropped, .backingReward:
      guard let projectId = activity.projectId else { return nil }
      return .tab(.dashboard(project: .id(projectId)))

    case .follow:
      return .tab(.activity)

    case .funding, .unknown, .watch:
      return nil
    }
  }

  if let project = envelope.project {
    if envelope.forCreator == .some(true) {
      return .tab(.dashboard(project: .id(project.id)))
    }
    return .project(.id(project.id), .root, refTag: .push)
  }

  if let message = envelope.message {
    if envelope.forCreator == .some(true) {
      return .creatorMessages(.id(message.projectId), messageThreadId: message.messageThreadId)
    } else {
      return .messages(messageThreadId: message.messageThreadId)
    }
  }

  if let survey = envelope.survey {
    return .user(.slug("self"), .survey(survey.id))
  }

  if let update = envelope.update {
    return .project(.id(update.projectId), .update(update.id, .root), refTag: .push)
  }

  if let erroredPledge = envelope.erroredPledge {
    return .project(.id(erroredPledge.projectId), .pledge(.manage), refTag: .push)
  }

  return nil
}

// Figures out a `Navigation` to route the user to from a shortcut item.
private func navigation(fromShortcutItem shortcutItem: ShortcutItem) -> SignalProducer<Navigation?, Never> {
  switch shortcutItem {
  case .creatorDashboard:
    return SignalProducer(value: .tab(.dashboard(project: nil)))

  case .recommendedForYou:
    let params = .defaults
      |> DiscoveryParams.lens.recommended .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    return SignalProducer(value: .tab(.discovery(params.queryParams)))

  case .projectsWeLove:
    let params = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    return SignalProducer(value: .tab(.discovery(params.queryParams)))

  case .search:
    return SignalProducer(value: .tab(.search))
  }
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
private func shortcutItems(isProjectMember: Bool, hasRecommendations: Bool)
  -> [ShortcutItem] {
  var items: [ShortcutItem] = []

  if isProjectMember {
    items.append(.creatorDashboard)
  }

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
    case .creatorDashboard:
      return .init(
        type: self.typeString,
        localizedTitle: Strings.accessibility_discovery_buttons_creator_dashboard(),
        localizedSubtitle: nil,
        icon: UIApplicationShortcutIcon(templateImageName: "shortcut-icon-bars"),
        userInfo: nil
      )
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

private func optimizelyData(for environment: Environment) -> (String, OptimizelyLogLevelType, TimeInterval) {
  let environmentType = environment.environmentType
  let logLevel = environment.mainBundle.isDebug ? OptimizelyLogLevelType.debug : OptimizelyLogLevelType.error
  let dispatchInterval: TimeInterval = 5

  var sdkKey: String

  switch environmentType {
  case .production:
    sdkKey = Secrets.OptimizelySDKKey.production
  case .staging:
    sdkKey = Secrets.OptimizelySDKKey.staging
  case .development, .local, .custom:
    sdkKey = Secrets.OptimizelySDKKey.development
  }

  return (sdkKey, logLevel, dispatchInterval)
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

private func qualtricsConfigData() -> QualtricsConfigData {
  return .init(
    brandId: Secrets.Qualtrics.brandId,
    zoneId: Secrets.Qualtrics.zoneId,
    interceptId: QualtricsIntercept.survey.interceptId,
    stringProperties: [
      "bundle_id": AppEnvironment.current.mainBundle.bundleIdentifier,
      "language": AppEnvironment.current.language.rawValue,
      "logged_in": "\(AppEnvironment.current.currentUser != nil)",
      "distinct_id": AppEnvironment.current.device.identifierForVendor?.uuidString,
      "user_uid": AppEnvironment.current.currentUser.flatMap { $0.id }.map(String.init)
    ]
    .compact()
  )
}

private func shouldSeeCategoryPersonalization() -> Bool {
  let isLoggedIn = AppEnvironment.current.currentUser != nil
  let hasSeenCategoryPersonalization = AppEnvironment.current.userDefaults.hasSeenCategoryPersonalizationFlow

  if isLoggedIn || hasSeenCategoryPersonalization {
    // Currently logged-in users should not see the onboarding flow
    AppEnvironment.current.userDefaults.hasSeenCategoryPersonalizationFlow = true

    return false
  }

  guard let variant = AppEnvironment.current.optimizelyClient?
    .variant(for: .onboardingCategoryPersonalizationFlow) else {
    return false
  }

  switch variant {
  case .control, .variant2:
    return false
  case .variant1:
    return true
  }
}

private func shouldGoToLandingPage() -> Bool {
  let hasNotSeenLandingPage = !AppEnvironment.current.userDefaults.hasSeenLandingPage

  guard AppEnvironment.current.currentUser == nil, hasNotSeenLandingPage else {
    AppEnvironment.current.userDefaults.hasSeenLandingPage = true

    return false
  }

  let optimizelyVariant = AppEnvironment.current.optimizelyClient?
    .variant(for: OptimizelyExperiment.Key.nativeOnboarding)

  switch optimizelyVariant {
  case .variant1, .variant2:
    return hasNotSeenLandingPage
  case .control, nil:
    return false
  }
}
