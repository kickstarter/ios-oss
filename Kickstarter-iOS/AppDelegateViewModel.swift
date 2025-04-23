import AppboyKit
import KsApi
import Library
import Prelude
import ReactiveSwift
import UserNotifications

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

  /// Call when the application becomes active `UIApplicationStateActive` and `UIApplicationStateInactive`
  func applicationActive(state: Bool)

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

  /// Call when the Braze SDK will display an in-app message, return a display choice.
  func brazeWillDisplayInAppMessage(_ message: BrazeInAppMessageType) -> ABKInAppMessageDisplayChoice

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

  /// Call when the redirect URL has been found, see `findRedirectUrl` for more information.
  func foundRedirectUrl(_ url: URL)

  /// Call when Remote Config configuration has failed
  func remoteConfigClientConfigurationFailed()

  /// Call when the contextual PushNotification dialog should be presented.
  func showNotificationDialog(notification: Notification)

  /// Call when Braze in-app notifications send a valid URL.
  func urlFromBrazeInAppNotification(_ url: URL?)

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

  /// Return this value in the delegate method.
  var continueUserActivityReturnValue: MutableProperty<Bool> { get }

  /// Emits the response from email verification with a message and success/failure.
  var emailVerificationCompleted: Signal<(String, Bool), Never> { get }

  /// Emits when the view needs to figure out the redirect URL for the emitted URL.
  /// Required in order to handle email links.
  var findRedirectUrl: Signal<URL, Never> { get }

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

  /// Emits when the root view controller should navigate to the user's profile.
  var goToProfile: Signal<(), Never> { get }

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

  /// Emits when we should register the device push token in Segment Analytics.
  var registerPushTokenInSegment: Signal<Data, Never> { get }

  /// Emits when  application didFinishLaunchingWithOptions.
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

    self.registerPushTokenInSegment = self.deviceTokenDataProperty.signal

    // Deep links. For more information, see
    // https://app.getguru.com/card/cyRdjqgi/How-iOS-Universal-Links-work

    let deepLinkFromNotification = self.remoteNotificationProperty.signal.skipNil()
      .map(PushEnvelope.decodeJSONDictionary)
      .skipNil()
      .map(navigation(fromPushEnvelope:))

    let urlFromBrazeNotification = self.remoteNotificationProperty.signal.skipNil()
      .map(BrazePushEnvelope.decodeJSONDictionary)
      .skipNil()
      .map { $0.abURI }
      .skipNil()
      .map(URL.init(string:))
      .skipNil()

    let urlFromBraze = Signal
      .merge(
        urlFromBrazeNotification,
        self.brazeInAppNotificationURLProperty.signal.skipNil()
      )

    let deepLinkFromBraze = urlFromBraze.map(Navigation.deepLinkMatch)

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
        deepLinkFromBraze,
        deepLinkFromShortcut
      )
      .skipNil()

    let deepLink = deeplinkActivated

    let updatedUserNotificationSettings = deepLink.filter { nav in
      guard case .settings(.notifications(_, _)) = nav else { return false }
      return true
    }
    .flatMap(updateUserNotificationSetting)

    self.updateCurrentUserInEnvironment = Signal.merge(
      currentUserEvent.values().skipNil(),
      updatedUserNotificationSettings
    )

    let emailVerificationEvent = deepLinkUrl
      .filter { Navigation.match($0) == .profile(.verifyEmail) }
      .map(accessTokenFromUrl)
      .skipNil()
      .switchMap { accessToken in
        AppEnvironment.current.apiService.verifyEmail(withToken: accessToken)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.emailVerificationCompleted = emailVerificationEvent
      .map(emailVerificationCompletionData)
      .skipNil()

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
          let params = DiscoveryParams.decodeJSONDictionary(rawParams)
        else {
          return .init(value: nil)
        }

        let deepLinkCategories = deepLinkCategories(rawParams: rawParams)

        guard let categoryParam = deepLinkCategories.0 else {
          return .init(value: params)
        }

        return AppEnvironment.current.apiService.fetchGraphCategories()
          .map { envelope in
            findCategoryFromRootCategories(
              envelope: envelope,
              categoryParam: categoryParam,
              subcategoryParam: deepLinkCategories.1
            )
          }
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
          .map { params |> DiscoveryParams.lens.category .~ $0 }
      }

    let projectLinkValues = deepLink
      .map { link -> (Param, Navigation.Project, RefInfo?)? in
        guard case let .project(param, subpage, refInfo) = link else { return nil }
        return (param, subpage, refInfo)
      }
      .skipNil()
      .switchMap { param, subpage, refInfo in
        AppEnvironment.current.apiService.fetchProject(param: param)
          .demoteErrors()
          .observeForUI()
          .map { project -> (Project, Navigation.Project, [UIViewController], RefInfo?) in
            let projectParam = Either<Project, any ProjectPageParam>(left: project)
            let vc = ProjectPageViewController.configuredWith(
              projectOrParam: projectParam,
              refInfo: refInfo
            )

            return (
              project, subpage,
              [vc],
              refInfo
            )
          }
      }

    let projectLink = projectLinkValues
      .filter { project, _, _, _ in project.displayPrelaunch != true }

    let projectPreviewLink = projectLinkValues
      .filter { project, _, _, _ in project.displayPrelaunch == true }

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

    self.goToProfile = deepLink
      .filter { $0 == .tab(.me) }
      .ignoreValues()

    let resolvedRedirectUrl = Signal.merge(
      deepLinkUrl,
      urlFromBraze
    )
    .filter { Navigation.deepLinkMatch($0) == nil }

    self.goToMobileSafari = resolvedRedirectUrl

    let projectRootLink = Signal.merge(projectLink, projectPreviewLink)
      .filter { _, subpage, _, _ in subpage == .root }
      .map { _, _, vcs, _ in vcs }

    let projectCommentsLink = projectLink
      .filter { _, subpage, _, _ in subpage == .comments }
      .map { project, _, vcs, _ in
        vcs + [commentsViewController(for: project, update: nil)]
      }

    let projectCommentThreadLink = projectLink
      .observeForUI()
      .switchMap { project, subpage, vcs, _ -> SignalProducer<[UIViewController], Never> in
        guard case let .commentThread(commentId, replyId) = subpage,
              let commentId = commentId else {
          return .empty
        }

        return AppEnvironment.current.apiService
          .fetchCommentReplies(
            id: commentId,
            cursor: nil,
            limit: CommentRepliesEnvelope.paginationLimit,
            withStoredCards: false
          )
          .demoteErrors()
          .observeForUI()
          .map { envelope in
            vcs + [
              commentsViewController(for: project, update: nil),
              CommentRepliesViewController.configuredWith(
                comment: envelope.comment,
                project: project,
                update: nil,
                inputAreaBecomeFirstResponder: false,
                replyId: replyId
              )
            ]
          }
      }

    let surveyUrlFromUserLink = deepLink
      .map { link -> Int? in
        if case let .user(_, .survey(surveyResponseId)) = link { return surveyResponseId }
        return nil
      }
      .skipNil()
      .switchMap { surveyResponseId in
        AppEnvironment.current.apiService.fetchSurveyResponse(surveyResponseId: surveyResponseId)
          .demoteErrors()
          .map { surveyResponse -> String in
            surveyResponse.urls.web.survey
          }
      }

    let surveyUrlFromProjectLink = deepLink
      .map { link -> String? in
        if case let .project(_, .surveyWebview(surveyUrl), _) = link {
          return surveyUrl
        }
        return nil
      }
      .skipNil()

    let surveyResponseLink = Signal.merge(surveyUrlFromProjectLink, surveyUrlFromUserLink)
      .observeForUI()
      .map { url -> [UIViewController] in
        [SurveyResponseViewController.configuredWith(surveyUrl: url)]
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
        return vcs + [commentsViewController(update: update)]
      }
      .skipNil()

    let updateCommentThreadLink = updateLink
      .observeForUI()
      .switchMap { project, update, subpage, vcs -> SignalProducer<[UIViewController], Never> in
        guard case let .commentThread(commentId, replyId) = subpage,
              let commentId = commentId else {
          return .empty
        }
        return AppEnvironment.current.apiService
          .fetchCommentReplies(
            id: commentId,
            cursor: nil,
            limit: CommentRepliesEnvelope.paginationLimit,
            withStoredCards: false
          )
          .demoteErrors()
          .observeForUI()
          .map { envelope in
            vcs + [
              commentsViewController(for: nil, update: update),
              CommentRepliesViewController.configuredWith(
                comment: envelope.comment,
                project: project,
                update: update,
                inputAreaBecomeFirstResponder: false,
                replyId: replyId
              )
            ]
          }
      }

    let viewControllersContainedInNavigationController = Signal
      .merge(
        projectRootLink,
        projectCommentsLink,
        projectCommentThreadLink,
        surveyResponseLink,
        updatesLink,
        updateRootLink,
        updateCommentsLink,
        updateCommentThreadLink
      )
      .map { UINavigationController() |> UINavigationController.lens.viewControllers .~ $0 }

    self.presentViewController = Signal.merge(
      viewControllersContainedInNavigationController.map { $0 as UIViewController },
      fixErroredPledgeLink.map { $0 as UIViewController }
    )

    self.configureFirebase = self.applicationLaunchOptionsProperty.signal.ignoreValues()

    self.setApplicationShortcutItems = currentUserEvent
      .values()
      .switchMap(shortcutItems(forUser:))

    self.applicationDidFinishLaunchingReturnValueProperty <~ self.applicationLaunchOptionsProperty.signal
      .skipNil()
      .map { _, options in options?[UIApplication.LaunchOptionsKey.shortcutItem] == nil }

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

    self.brazeWillDisplayInAppMessageReturnProperty <~ self.brazeWillDisplayInAppMessageProperty.signal
      .skipNil()
      .map { _ in .displayInAppMessageNow }

    self.requestATTrackingAuthorizationStatus = Signal
      .combineLatest(
        self.applicationDidFinishLaunchingReturnValueProperty.signal.ignoreValues(),
        self.applicationActiveProperty.signal
      )
      .map(second)
      .skipRepeats()
      .ksr_delay(.seconds(1), on: AppEnvironment.current.scheduler)
      .filter(isTrue)
      .map { _ in AppEnvironment.current.appTrackingTransparency }
      .map { appTrackingTransparency in
        if
          appTrackingTransparency.advertisingIdentifier == nil &&
          appTrackingTransparency.shouldRequestAuthorizationStatus() {
          appTrackingTransparency.requestAndSetAuthorizationStatus()
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

  private let brazeWillDisplayInAppMessageProperty = MutableProperty<BrazeInAppMessageType?>(nil)
  private let brazeWillDisplayInAppMessageReturnProperty
    = MutableProperty<ABKInAppMessageDisplayChoice>(.discardInAppMessage)
  public func brazeWillDisplayInAppMessage(_ message: BrazeInAppMessageType) -> ABKInAppMessageDisplayChoice {
    self.brazeWillDisplayInAppMessageProperty.value = message
    return self.brazeWillDisplayInAppMessageReturnProperty.value
  }

  fileprivate let performActionForShortcutItemProperty = MutableProperty<UIApplicationShortcutItem?>(nil)
  public func applicationPerformActionForShortcutItem(_ item: UIApplicationShortcutItem) {
    self.performActionForShortcutItemProperty.value = item
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

  private let foundRedirectUrlProperty = MutableProperty<URL?>(nil)
  public func foundRedirectUrl(_ url: URL) {
    self.foundRedirectUrlProperty.value = url
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

  fileprivate let brazeInAppNotificationURLProperty = MutableProperty<URL?>(nil)
  public func urlFromBrazeInAppNotification(_ url: URL?) {
    self.brazeInAppNotificationURLProperty.value = url
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
  public let continueUserActivityReturnValue = MutableProperty(false)
  public let emailVerificationCompleted: Signal<(String, Bool), Never>
  public let findRedirectUrl: Signal<URL, Never>
  public let forceLogout: Signal<(), Never>
  private let fetchUserEmail: Signal<(), Never>
  public let goToActivity: Signal<(), Never>
  public let goToDiscovery: Signal<DiscoveryParams?, Never>
  public let goToLoginWithIntent: Signal<LoginIntent, Never>
  public let goToMessageThread: Signal<MessageThread, Never>
  public let goToProfile: Signal<(), Never>
  public let goToMobileSafari: Signal<URL, Never>
  public let goToSearch: Signal<(), Never>
  public let postNotification: Signal<Notification, Never>
  public let presentViewController: Signal<UIViewController, Never>
  public let pushTokenRegistrationStarted: Signal<(), Never>
  public let pushTokenSuccessfullyRegistered: Signal<String, Never>
  public let registerPushTokenInSegment: Signal<Data, Never>
  public let requestATTrackingAuthorizationStatus: Signal<Void, Never>
  public let segmentIsEnabled: Signal<Bool, Never>
  public let setApplicationShortcutItems: Signal<[ShortcutItem], Never>
  public let showAlert: Signal<Notification, Never>
  public let synchronizeUbiquitousStore: Signal<(), Never>
  public let trackingAuthorizationStatus: SignalProducer<AppTrackingAuthorization, Never>
  public let unregisterForRemoteNotifications: Signal<(), Never>
  public let updateCurrentUserInEnvironment: Signal<User, Never>
  public let updateConfigInEnvironment: Signal<Config, Never>
}

/// Handles the deeplink route with both an id and text based name for a deeplink to categories.
private func deepLinkCategories(rawParams: [String: String]) -> (Param?, Param?) {
  let parentCategoryParams = rawParams["parent_category_id"]
  let subCategoryParams = rawParams["category_id"]
  var categoryParam: Param?
  var subcategoryParam: Param?

  let rawId: (String?) -> Int? = { rawParam in
    guard let rawParamValue = rawParam else {
      return .none
    }

    return Int(rawParamValue)
  }

  let rawName: (String?) -> String? = { rawParam in
    guard let rawParamValue = rawParam else {
      return .none
    }

    return String(rawParamValue)
  }

  if let categoryId = rawId(parentCategoryParams) {
    categoryParam = Param.id(categoryId)
  } else if let categoryName = rawName(parentCategoryParams) {
    categoryParam = Param.slug(categoryName)
  }

  if let subcategoryId = rawId(subCategoryParams) {
    subcategoryParam = Param.id(subcategoryId)
  } else if let subcategoryName = rawName(subCategoryParams) {
    subcategoryParam = Param.slug(subcategoryName)
  }

  let subCategoryWithNoParentCategory = categoryParam == nil && subcategoryParam != nil

  categoryParam = subCategoryWithNoParentCategory ? subcategoryParam : categoryParam
  subcategoryParam = subCategoryWithNoParentCategory ? nil : subcategoryParam

  return (categoryParam, subcategoryParam)
}

/// Will check id and name of category and subcategory against all available categories and subcategories inside envelope
private func findCategoryFromRootCategories(
  envelope: RootCategoriesEnvelope,
  categoryParam: Param,
  subcategoryParam: Param?
) -> KsApi.Category? {
  let allRootCategoryIdsAndNames = envelope.rootCategories.compactMap { $0 }

  let allSubcategoryIdsAndNames = envelope.rootCategories.compactMap { $0.subcategories?.nodes }
    .flatMap { $0 }

  let allCategoryIdsAndNames = allRootCategoryIdsAndNames + allSubcategoryIdsAndNames

  let routableCategory = allCategoryIdsAndNames.first(where: { category in
    category.intID == categoryParam.id || category.name.lowercased() == categoryParam.slug?.lowercased()
  })

  let routableSubcategory = routableCategory != nil ? allCategoryIdsAndNames.first(where: { category in
    category.intID == subcategoryParam?.id || category.name.lowercased() == subcategoryParam?.slug?
      .lowercased()
  }) : nil

  return routableSubcategory ?? routableCategory
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

  if let pledgeRedemption = envelope.pledgeRedemption {
    let path = pledgeRedemption.pledgeManagerPath
    let url = AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString + path
    return .project(.id(pledgeRedemption.projectId), .surveyWebview(url), refInfo: RefInfo(.push))
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
    return .project(.id(survey.projectId), .surveyWebview(url), refInfo: RefInfo(.push))
  }

  if let update = envelope.update {
    return .project(.id(update.projectId), .update(update.id, .root), refInfo: RefInfo(.push))
  }

  if let erroredPledge = envelope.erroredPledge {
    return .project(.id(erroredPledge.projectId), .pledge(.manage), refInfo: RefInfo(.push))
  }

  return nil
}

// Figures out a `Navigation` to route the user to from a shortcut item.
private func navigation(fromShortcutItem shortcutItem: ShortcutItem) -> SignalProducer<Navigation?, Never> {
  switch shortcutItem {
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

private func accessTokenFromUrl(_ url: URL?) -> String? {
  return url.flatMap { url in
    URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
  }?
    .first { item in item.name == "at" }?
    .value
}

private func emailVerificationCompletionData(
  event: Signal<EmailVerificationResponseEnvelope, ErrorEnvelope>.Event
) -> (String, Bool)? {
  guard !event.isCompleted else { return nil }

  guard isNil(event.error), let message = event.value?.message else {
    let message = event.error?.errorMessages.first ?? Strings.Something_went_wrong_please_try_again()

    return (message, false)
  }

  return (message, true)
}

private func configRetainingDebugFeatureFlags(_ config: Config) -> Config {
  guard AppEnvironment.current.mainBundle.isRelease == false else { return config }

  let currentFeatures = config.features
  let currentFeatureKeys = Set(currentFeatures.keys)

  let storedFeatures = (AppEnvironment.current.config?.features ?? [:])
    .filter { key, _ in currentFeatureKeys.contains(key) }

  return config |> Config.lens.features .~ currentFeatures.withAllValuesFrom(storedFeatures)
}

private func updateUserNotificationSetting(navigation: Navigation) -> SignalProducer<User, Never> {
  guard
    case let .settings(.notifications(notification, enabled)) = navigation,
    let currentUser = AppEnvironment.current.currentUser
  else { return .empty }

  let currentNotifications = AppEnvironment.current.currentUser?.notifications.encode()
  let updatedNotifications = currentNotifications?.withAllValuesFrom([notification: enabled])

  guard
    let data = try? JSONSerialization.data(withJSONObject: updatedNotifications as Any, options: []),
    let userNotifications = try? JSONDecoder().decode(User.Notifications.self, from: data)
  else { return .empty }

  let updatedUser = currentUser |> User.lens.notifications .~ userNotifications

  return AppEnvironment.current.apiService.updateUserSelf(updatedUser)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
    .demoteErrors()
}
