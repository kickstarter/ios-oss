import Argo
import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import Result
import UserNotifications

public struct HockeyConfigData {
  public let appIdentifier: String
  public let disableUpdates: Bool
  public let userId: String
  public let userName: String
}

extension HockeyConfigData: Equatable {}
public func == (lhs: HockeyConfigData, rhs: HockeyConfigData) -> Bool {
  return lhs.appIdentifier == rhs.appIdentifier
    && lhs.disableUpdates == rhs.disableUpdates
    && lhs.userId == rhs.userId
    && lhs.userName == rhs.userName
}

public enum NotificationAuthorizationStatus {
  case authorized
  case denied
  case notDetermined
}

public protocol AppDelegateViewModelInputs {
  /// Call when the application is handed off to.
  func applicationContinueUserActivity(_ userActivity: NSUserActivity) -> Bool

  /// Call when the application finishes launching.
  func applicationDidFinishLaunching(application: UIApplication?, launchOptions: [AnyHashable: Any]?)

  /// Call when the application will enter foreground.
  func applicationWillEnterForeground()

  /// Call when the application enters background.
  func applicationDidEnterBackground()

  /// Call when the aplication receives memory warning from the system.
  func applicationDidReceiveMemoryWarning()

  /// Call to open a url that was sent to the app
  func applicationOpenUrl(application: UIApplication?,
                          url: URL,
                          sourceApplication: String?,
                          annotation: Any) -> Bool

  /// Call when the application receives a request to perform a shortcut action.
  func applicationPerformActionForShortcutItem(_ item: UIApplicationShortcutItem)

  /// Call after having invoked AppEnvironemt.updateCurrentUser with a fresh user.
  func currentUserUpdatedInEnvironment()

  /// Call when the app delegate receives a remote notification.
  func didReceive(remoteNotification notification: [AnyHashable: Any], applicationIsActive: Bool)

  /// Call when the app delegate gets notice of a successful notification registration.
  func didRegisterForRemoteNotifications(withDeviceTokenData data: Data)

  /// Call when the redirect URL has been found, see `findRedirectUrl` for more information.
  func foundRedirectUrl(_ url: URL)

  /// Call when notification authorization is completed with user permission or denial.
  func notificationAuthorizationCompleted(isGranted: Bool)

  /// Call when notification authorization status received.
  @available(iOS 10.0, *)
  func notificationAuthorizationStatusReceived(_ authorizationStatus: UNAuthorizationStatus)

  /// Call when the user taps "OK" from the notification alert.
  func openRemoteNotificationTappedOk()

  /// Call when the controller has received a user session ended notification.
  func userSessionEnded()

  /// Call when the controller has received a user session started notification.
  func userSessionStarted()

  /// Call when the app has crashed
  func crashManagerDidFinishSendingCrashReport()
}

public protocol AppDelegateViewModelOutputs {
  /// The value to return from the delegate's `application:didFinishLaunchingWithOptions:` method.
  var applicationDidFinishLaunchingReturnValue: Bool { get }

  /// Emits when application should request authorizatoin for notifications.
  var authorizeForRemoteNotifications: Signal<(), NoError> { get }

  /// Emits an app identifier that should be used to configure the hockey app manager.
  var configureHockey: Signal<HockeyConfigData, NoError> { get }

  /// Return this value in the delegate method.
  var continueUserActivityReturnValue: MutableProperty<Bool> { get }

  /// Return this value in the delegate method.
  var facebookOpenURLReturnValue: MutableProperty<Bool> { get }

  /// Emits when the view needs to figure out the redirect URL for the emitted URL.
  var findRedirectUrl: Signal<URL, NoError> { get }

  /// Emits when opening the app with an invalid access token.
  var forceLogout: Signal<(), NoError> { get }

  /// Emits when application should call getNotificationSettings() to obtain authorization status.
  var getNotificationAuthorizationStatus: Signal<(), NoError> { get }

  /// Emits when the root view controller should navigate to activity.
  var goToActivity: Signal<(), NoError> { get }

  /// Emits when application should navigate to the creator's message thread
  var goToCreatorMessageThread: Signal<(Param, MessageThread), NoError> { get }

  /// Emits when the root view controller should navigate to the creator dashboard.
  var goToDashboard: Signal<Param?, NoError> { get }

  /// Emits when the root view controller should navigate to the creator dashboard.
  var goToDiscovery: Signal<DiscoveryParams?, NoError> { get }

  /// Emits everything needed to go a particular live stream of a project.
  var goToLiveStream: Signal<(Project, LiveStreamEvent, RefTag?), NoError> { get }

  /// Emits when the root view controller should navigate to the login screen.
  var goToLogin: Signal<(), NoError> { get }

  /// Emits a message thread when we should navigate to it.
  var goToMessageThread: Signal<MessageThread, NoError> { get }

  /// Emits when the root view controller should navigate to the user's profile.
  var goToProfile: Signal<(), NoError> { get }

  /// Emits when should navigate to the project activities view
  var goToProjectActivities: Signal<Param, NoError> { get }

  /// Emits a URL when we should open it in the safari browser.
  var goToMobileSafari: Signal<URL, NoError> { get }

  /// Emits when the root view controller should navigate to search.
  var goToSearch: Signal<(), NoError> { get }

  /// Emits an Notification that should be immediately posted.
  var postNotification: Signal<Notification, NoError> { get }

  /// Emits a message when a remote notification alert should be displayed to the user.
  var presentRemoteNotificationAlert: Signal<String, NoError> { get }

  /// Emits when a view controller should be presented.
  var presentViewController: Signal<UIViewController, NoError> { get }

  /// Emits when the push token has been successfully registered on the server.
  var pushTokenSuccessfullyRegistered: Signal<(), NoError> { get }

  /// Emits when we should attempt registering the user for notifications.
  var registerForRemoteNotifications: Signal<(), NoError> { get }

  /// Emits an array of short cut items to put into the shared application.
  var setApplicationShortcutItems: Signal<[ShortcutItem], NoError> { get }

  /// Emits to synchronize iCloud on app launch.
  var synchronizeUbiquitousStore: Signal<(), NoError> { get }

  /// Emits when we should unregister the user from notifications.
  var unregisterForRemoteNotifications: Signal<(), NoError> { get }

  /// Emits a fresh user to be updated in the app environment.
  var updateCurrentUserInEnvironment: Signal<User, NoError> { get }

  /// Emits a config value that should be updated in the environment.
  var updateConfigInEnvironment: Signal<Config, NoError> { get }
}

public protocol AppDelegateViewModelType {
  var inputs: AppDelegateViewModelInputs { get }
  var outputs: AppDelegateViewModelOutputs { get }
}

public final class AppDelegateViewModel: AppDelegateViewModelType, AppDelegateViewModelInputs,
AppDelegateViewModelOutputs {

  // swiftlint:disable cyclomatic_complexity
  public init() {
    let currentUserEvent = Signal
      .merge(
        self.applicationWillEnterForegroundProperty.signal,
        self.applicationLaunchOptionsProperty.signal.ignoreValues(),
        self.userSessionEndedProperty.signal,
        self.userSessionStartedProperty.signal
      )
      .ksr_debounce(.seconds(5), on: AppEnvironment.current.scheduler)
      .switchMap { _ -> SignalProducer<Event<User?, ErrorEnvelope>, NoError> in
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

    self.updateConfigInEnvironment = Signal.merge([
      self.applicationWillEnterForegroundProperty.signal,
      self.applicationLaunchOptionsProperty.signal.ignoreValues()
      ])
      .switchMap { AppEnvironment.current.apiService.fetchConfig().demoteErrors() }

    self.postNotification = self.currentUserUpdatedInEnvironmentProperty.signal
      .mapConst(Notification(name: .ksr_userUpdated, object: nil))

    self.applicationLaunchOptionsProperty.signal.skipNil()
      .take(first: 1)
      .observeValues { appOptions in
        _ = AppEnvironment.current.facebookAppDelegate.application(
          appOptions.application,
          didFinishLaunchingWithOptions: appOptions.options
        )
    }

    let openUrl = self.applicationOpenUrlProperty.signal.skipNil()

    self.facebookOpenURLReturnValue <~ openUrl.map {
      AppEnvironment.current.facebookAppDelegate.application(
        $0.application, open: $0.url, sourceApplication: $0.sourceApplication, annotation: $0.annotation
      )
    }

    // iCloud

    self.synchronizeUbiquitousStore = self.applicationLaunchOptionsProperty.signal.ignoreValues()

    // Push notifications

    let applicationIsReadyForRegisteringNotifications = Signal.merge(
      self.applicationWillEnterForegroundProperty.signal,
      self.applicationLaunchOptionsProperty.signal.ignoreValues(),
      self.userSessionStartedProperty.signal
      )
      .filter { AppEnvironment.current.currentUser != nil }

    if #available(iOS 10.0, *) {
      self.getNotificationAuthorizationStatus = applicationIsReadyForRegisteringNotifications

      self.registerForRemoteNotifications = self.notificationAuthorizationCompletedProperty.signal
        .filter(isTrue)
        .ignoreValues()
    } else {
      //Never firing signal in ios 9
      self.getNotificationAuthorizationStatus = .empty

      self.registerForRemoteNotifications = applicationIsReadyForRegisteringNotifications
    }

    self.authorizeForRemoteNotifications = Signal.merge(
      applicationIsReadyForRegisteringNotifications,
      self.notificationAuthorizationStatusProperty.signal
        .skipNil()
        .filter { $0 == .notDetermined }
        .ignoreValues()
    )

    self.unregisterForRemoteNotifications = self.userSessionEndedProperty.signal

    self.pushTokenSuccessfullyRegistered = self.deviceTokenDataProperty.signal
      .map(deviceToken(fromData:))
      .ksr_debounce(.seconds(5), on: AppEnvironment.current.scheduler)
      .switchMap {
        AppEnvironment.current.apiService.register(pushToken: $0)
          .demoteErrors()
      }
      .ignoreValues()

    let remoteNotificationFromLaunch = self.applicationLaunchOptionsProperty.signal.skipNil()
      .map { _, options in options?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] }
      .skipNil()

    let localNotificationFromLaunch = self.applicationLaunchOptionsProperty.signal.skipNil()
      .map { _, options in options?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification }
      .map { $0?.userInfo }
      .skipNil()

    let notificationAndIsActive = Signal.merge(
      self.remoteNotificationAndIsActiveProperty.signal.skipNil(),
      remoteNotificationFromLaunch.map { ($0, false) },
      localNotificationFromLaunch.map { ($0, false) }
    )

    let pushEnvelopeAndIsActive = notificationAndIsActive
      .map { (notification, isActive) -> (PushEnvelope, Bool)? in
        guard let envelope = (decode(notification) as Decoded<PushEnvelope>).value else { return nil }
        return (envelope, isActive)
      }
      .skipNil()

    self.presentRemoteNotificationAlert = pushEnvelopeAndIsActive
      .filter(second)
      .map { env, _ in env.aps.alert }

    let explicitlyOpenedNotification = pushEnvelopeAndIsActive
      .takeWhen(self.openRemoteNotificationTappedOkProperty.signal)

    let pushEnvelope = Signal.merge(
      pushEnvelopeAndIsActive.filter(second >>> isFalse),
      explicitlyOpenedNotification
      )
      .map(first)

    let deepLinkFromNotification = pushEnvelope
      .map(navigation(fromPushEnvelope:))

    // Deep links

    let continueUserActivity = self.applicationContinueUserActivityProperty.signal.skipNil()

    let continueUserActivityWithNavigation = continueUserActivity
      .filter { $0.activityType == NSUserActivityTypeBrowsingWeb }
      .map { activity in (activity, activity.webpageURL.flatMap(Navigation.match)) }
      .filter(second >>> isNotNil)

    self.continueUserActivityReturnValue <~ continueUserActivityWithNavigation.mapConst(true)

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
        .map { $0?.options?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem }
        .skipNil()
      )
      .map { ShortcutItem(typeString: $0.type) }
      .skipNil()

    let deepLinkFromShortcut = performShortcutItem
      .switchMap(navigation(fromShortcutItem:))

    let deepLink = Signal
      .merge(
        deepLinkFromUrl,
        deepLinkFromNotification,
        deepLinkFromShortcut
      )
      .skipNil()

    self.findRedirectUrl = deepLinkUrl
      .filter {
        switch Navigation.match($0) {
        case .some(.emailClick), .some(.emailLink): return true
        default:                                    return false
        }
    }

    self.goToDiscovery = deepLink
      .map { link -> [String: String]?? in
        guard case let .tab(.discovery(rawParams)) = link else { return nil }
        return .some(rawParams)
      }
      .skipNil()
      .switchMap { rawParams -> SignalProducer<DiscoveryParams?, NoError> in
        guard
          let rawParams = rawParams,
          let params = DiscoveryParams.decode(.init(rawParams)).value
          else { return .init(value: nil) }

        guard
          let rawCategoryParam = rawParams["category_id"],
          let categoryParam = Param.decode(.string(rawCategoryParam)).value
          else { return .init(value: params) }

        return AppEnvironment.current.apiService.fetchCategory(param: categoryParam)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
          .map { params |> DiscoveryParams.lens.category .~ $0 }
    }

    self.goToLiveStream = deepLink
      .switchMap(liveStreamData(fromNavigation:))

    self.goToActivity = deepLink
      .filter { $0 == .tab(.activity) }
      .ignoreValues()

    self.goToSearch = deepLink
      .filter { $0 == .tab(.search) }
      .ignoreValues()

    self.goToLogin = deepLink
      .filter { $0 == .tab(.login) }
      .ignoreValues()

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

    self.goToMobileSafari = self.foundRedirectUrlProperty.signal.skipNil()
      .filter { Navigation.deepLinkMatch($0) == nil }

    let projectLink = deepLink
      .filter { link in
        // NB: have to do this cause we handle the live stream subpage in a different manner than we do
        // the other subpages.
        if case .project(_, .liveStream, _) = link { return false }
        return true
      }
      .map { link -> (Param, Navigation.Project, RefTag?)? in
        guard case let .project(param, subpage, refTag) = link else { return nil }
        return (param, subpage, refTag)
      }
      .skipNil()
      .switchMap { param, subpage, refTag in
        AppEnvironment.current.apiService.fetchProject(param: param)
          .demoteErrors()
          .observeForUI()
          .map { project -> (Project, Navigation.Project, [UIViewController]) in
            (project, subpage,
              [ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: refTag)])
        }
    }

    self.goToDashboard = deepLink
      .map { link -> Param?? in
        guard case let .tab(.dashboard(param)) = link else { return nil }
        return .some(param)
      }
      .skipNil()

    let projectRootLink = projectLink
      .filter { _, subpage, _ in subpage == .root }
      .map { _, _, vcs in vcs }

    let projectCommentsLink = projectLink
      .filter { _, subpage, _ in subpage == .comments }
      .map { project, _, vcs in vcs + [CommentsViewController.configuredWith(project: project, update: nil)] }

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

    let updatesLink = projectLink
      .filter { _, subpage, _ in subpage == .updates }
      .map { project, _, vcs in vcs + [ProjectUpdatesViewController.configuredWith(project: project)] }

    let updateLink = projectLink
      .map { project, subpage, vcs -> (Project, Int, Navigation.Project.Update, [UIViewController])? in
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
              vcs + [UpdateViewController.configuredWith(project: project,
                                                         update: update,
                                                         context: .deepLink)]
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

    self.presentViewController = Signal
      .merge(
        projectRootLink,
        projectCommentsLink,
        surveyResponseLink,
        updatesLink,
        updateRootLink,
        updateCommentsLink
      )
      .map { UINavigationController() |> UINavigationController.lens.viewControllers .~ $0 }

    self.configureHockey = Signal.merge(
      self.applicationLaunchOptionsProperty.signal.ignoreValues(),
      self.userSessionStartedProperty.signal,
      self.userSessionEndedProperty.signal
      )
      .map { _ in
        let mainBundle = AppEnvironment.current.mainBundle
        let appIdentifier = mainBundle.isRelease
          ? KsApi.Secrets.HockeyAppId.production
          : KsApi.Secrets.HockeyAppId.beta

        return HockeyConfigData(
          appIdentifier: appIdentifier,
          disableUpdates: mainBundle.isRelease || mainBundle.isAlpha,
          userId: (AppEnvironment.current.currentUser?.id).map(String.init) ?? "0",
          userName: AppEnvironment.current.currentUser?.name ?? "anonymous"
        )
    }

    self.setApplicationShortcutItems = currentUserEvent
      .values()
      .switchMap(shortcutItems(forUser:))

    self.applicationDidFinishLaunchingReturnValueProperty <~ self.applicationLaunchOptionsProperty.signal
      .skipNil()
      .map { _, options in options?[UIApplicationLaunchOptionsKey.shortcutItem] == nil }

    // Koala

    self.notificationAuthorizationStatusProperty.signal
      .skipNil()
      .skip(until: self.notificationAuthorizationCompletedProperty.signal.ignoreValues())
      .take(first: 1)
      .observeValues { status in
        switch status {
        case .authorized:
          AppEnvironment.current.koala.trackPushPermissionOptIn()
        case .denied:
          AppEnvironment.current.koala.trackPushPermissionOptOut()
        case .notDetermined: ()
        }
      }

    Signal.merge(
      self.applicationLaunchOptionsProperty.signal.ignoreValues(),
      self.applicationWillEnterForegroundProperty.signal
      )
      .observeValues { AppEnvironment.current.koala.trackAppOpen() }

    self.applicationDidEnterBackgroundProperty.signal
      .observeValues { AppEnvironment.current.koala.trackAppClose() }

    self.applicationDidReceiveMemoryWarningProperty.signal
      .observeValues { AppEnvironment.current.koala.trackMemoryWarning() }

    self.crashManagerDidFinishSendingCrashReportProperty.signal
      .observeValues { AppEnvironment.current.koala.trackCrashedApp() }

    self.applicationLaunchOptionsProperty.signal
      .take(first: 1)
      .observeValues { _ in
        visitorCookies().forEach(AppEnvironment.current.cookieStorage.setCookie)
    }

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
      .map(first)
      .observeValues { AppEnvironment.current.koala.trackUserActivity($0) }

    deepLinkFromNotification
      .observeValues { _ in AppEnvironment.current.koala.trackNotificationOpened() }
  }
  // swiftlint:enable cyclomatic_complexity

  public var inputs: AppDelegateViewModelInputs { return self }
  public var outputs: AppDelegateViewModelOutputs { return self }

  fileprivate let applicationContinueUserActivityProperty = MutableProperty<NSUserActivity?>(nil)
  public func applicationContinueUserActivity(_ userActivity: NSUserActivity) -> Bool {
    self.applicationContinueUserActivityProperty.value = userActivity
    return self.continueUserActivityReturnValue.value
  }

  fileprivate typealias ApplicationWithOptions = (application: UIApplication?, options: [AnyHashable: Any]?)
  fileprivate let applicationLaunchOptionsProperty = MutableProperty<ApplicationWithOptions?>(nil)
  public func applicationDidFinishLaunching(application: UIApplication?,
                                            launchOptions: [AnyHashable: Any]?) {
    self.applicationLaunchOptionsProperty.value = (application, launchOptions)
  }

  fileprivate let applicationWillEnterForegroundProperty = MutableProperty()
  public func applicationWillEnterForeground() {
    self.applicationWillEnterForegroundProperty.value = ()
  }

  fileprivate let applicationDidEnterBackgroundProperty = MutableProperty()
  public func applicationDidEnterBackground() {
    self.applicationDidEnterBackgroundProperty.value = ()
  }

  fileprivate let applicationDidReceiveMemoryWarningProperty = MutableProperty()
  public func applicationDidReceiveMemoryWarning() {
    self.applicationDidReceiveMemoryWarningProperty.value = ()
  }

  fileprivate let performActionForShortcutItemProperty = MutableProperty<UIApplicationShortcutItem?>(nil)
  public func applicationPerformActionForShortcutItem(_ item: UIApplicationShortcutItem) {
    self.performActionForShortcutItemProperty.value = item
  }

  fileprivate let currentUserUpdatedInEnvironmentProperty = MutableProperty()
  public func currentUserUpdatedInEnvironment() {
    self.currentUserUpdatedInEnvironmentProperty.value = ()
  }

  fileprivate let configUpdatedInEnvironmentProperty = MutableProperty()
  public func configUpdatedInEnvironment() {
    self.configUpdatedInEnvironmentProperty.value = ()
  }

  fileprivate let remoteNotificationAndIsActiveProperty = MutableProperty<([AnyHashable: Any], Bool)?>(nil)
  public func didReceive(remoteNotification notification: [AnyHashable: Any], applicationIsActive: Bool) {
    self.remoteNotificationAndIsActiveProperty.value = (notification, applicationIsActive)
  }

  fileprivate let deviceTokenDataProperty = MutableProperty(Data())
  public func didRegisterForRemoteNotifications(withDeviceTokenData data: Data) {
    self.deviceTokenDataProperty.value = data
  }

  private let foundRedirectUrlProperty = MutableProperty<URL?>(nil)
  public func foundRedirectUrl(_ url: URL) {
    self.foundRedirectUrlProperty.value = url
  }

  fileprivate let crashManagerDidFinishSendingCrashReportProperty = MutableProperty()
  public func crashManagerDidFinishSendingCrashReport() {
    self.crashManagerDidFinishSendingCrashReportProperty.value = ()
  }

  fileprivate typealias ApplicationOpenUrl = (
    application: UIApplication?,
    url: URL,
    sourceApplication: String?,
    annotation: Any
  )
  fileprivate let applicationOpenUrlProperty = MutableProperty<ApplicationOpenUrl?>(nil)
  public func applicationOpenUrl(application: UIApplication?,
                                 url: URL,
                                 sourceApplication: String?,
                                 annotation: Any) -> Bool {
    self.applicationOpenUrlProperty.value = (application, url, sourceApplication, annotation)
    return self.facebookOpenURLReturnValue.value
  }

  fileprivate let openRemoteNotificationTappedOkProperty = MutableProperty()
  public func openRemoteNotificationTappedOk() {
    self.openRemoteNotificationTappedOkProperty.value = ()
  }

  fileprivate let userSessionEndedProperty = MutableProperty()
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let applicationDidFinishLaunchingReturnValueProperty = MutableProperty(true)
  public var applicationDidFinishLaunchingReturnValue: Bool {
    return applicationDidFinishLaunchingReturnValueProperty.value
  }

  fileprivate let notificationAuthorizationCompletedProperty = MutableProperty(false)
  public func notificationAuthorizationCompleted(isGranted: Bool) {
    self.notificationAuthorizationCompletedProperty.value = isGranted
  }

  fileprivate let notificationAuthorizationStatusProperty =
    MutableProperty<NotificationAuthorizationStatus?>(nil)
  @available(iOS 10.0, *)
  public func notificationAuthorizationStatusReceived(_ authorizationStatus: UNAuthorizationStatus) {
    return self.notificationAuthorizationStatusProperty.value = authStatusType(for: authorizationStatus)
  }

  public let authorizeForRemoteNotifications: Signal<(), NoError>
  public let configureHockey: Signal<HockeyConfigData, NoError>
  public let continueUserActivityReturnValue = MutableProperty(false)
  public let facebookOpenURLReturnValue = MutableProperty(false)
  public let findRedirectUrl: Signal<URL, NoError>
  public let forceLogout: Signal<(), NoError>
  public let getNotificationAuthorizationStatus: Signal<(), NoError>
  public let goToActivity: Signal<(), NoError>
  public let goToCreatorMessageThread: Signal<(Param, MessageThread), NoError>
  public let goToDashboard: Signal<Param?, NoError>
  public let goToDiscovery: Signal<DiscoveryParams?, NoError>
  public let goToLiveStream: Signal<(Project, LiveStreamEvent, RefTag?), NoError>
  public let goToLogin: Signal<(), NoError>
  public let goToMessageThread: Signal<MessageThread, NoError>
  public let goToProfile: Signal<(), NoError>
  public let goToProjectActivities: Signal<Param, NoError>
  public let goToMobileSafari: Signal<URL, NoError>
  public let goToSearch: Signal<(), NoError>
  public let postNotification: Signal<Notification, NoError>
  public let presentRemoteNotificationAlert: Signal<String, NoError>
  public let presentViewController: Signal<UIViewController, NoError>
  public let pushTokenSuccessfullyRegistered: Signal<(), NoError>
  public let registerForRemoteNotifications: Signal<(), NoError>
  public let setApplicationShortcutItems: Signal<[ShortcutItem], NoError>
  public let synchronizeUbiquitousStore: Signal<(), NoError>
  public let unregisterForRemoteNotifications: Signal<(), NoError>
  public let updateCurrentUserInEnvironment: Signal<User, NoError>
  public let updateConfigInEnvironment: Signal<Config, NoError>
}

private func deviceToken(fromData data: Data) -> String {

  return data
    .map { String(format: "%02.2hhx", $0 as CVarArg) }
    .joined()
}

// swiftlint:disable:next cyclomatic_complexity
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

  if let liveStream = envelope.liveStream, let project = envelope.project {
    return .project(.id(project.id), .liveStream(eventId: liveStream.id), refTag: .push)
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

  return nil
}

// Figures out a `Navigation` to route the user to from a shortcut item.
private func navigation(fromShortcutItem shortcutItem: ShortcutItem) -> SignalProducer<Navigation?, NoError> {

  switch shortcutItem {
  case .creatorDashboard:
    return SignalProducer(value: .tab(.dashboard(project: nil)))

  case .recommendedForYou:
    let params = .defaults
      |> DiscoveryParams.lens.recommended .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    return SignalProducer(value: .tab(.discovery(params.queryParams)))

  case .projectOfTheDay:
    let params = .defaults
      |> DiscoveryParams.lens.includePOTD .~ true
      |> DiscoveryParams.lens.perPage .~ 1
      |> DiscoveryParams.lens.sort .~ .magic
    return AppEnvironment.current.apiService.fetchDiscovery(params: params)
      .demoteErrors()
      .map { env -> Navigation? in
        guard let project = env.projects.first, project.isPotdToday(
          today: AppEnvironment.current.dateType.init().date) else { return nil }
        return .project(.id(project.id), .root, refTag: RefTag.unrecognized("shortcut"))
    }

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
private func shortcutItems(forUser user: User?) -> SignalProducer<[ShortcutItem], NoError> {

  guard let user = user else {
    return SignalProducer(value: shortcutItems(isProjectMember: false, hasRecommendations: false))
  }

  let recommendationParams = .defaults
    |> DiscoveryParams.lens.recommended .~ true
    |> DiscoveryParams.lens.state .~ .live
    |> DiscoveryParams.lens.perPage .~ 1

  let recommendationsCount = AppEnvironment.current.apiService.fetchDiscovery(params: recommendationParams)
    .map { $0.stats.count }
    .flatMapError { _ in SignalProducer<Int, NoError>(value: 0) }

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

    items.append(.projectOfTheDay)

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
    case .projectOfTheDay:
      return .init(
        type: self.typeString,
        localizedTitle: Strings.discovery_baseball_card_metadata_project_of_the_Day(),
        localizedSubtitle: nil,
        icon: UIApplicationShortcutIcon(templateImageName: "shortcut-icon-potd"),
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

private func liveStreamData(fromNavigation nav: Navigation)
  -> SignalProducer<(Project, LiveStreamEvent, RefTag?), NoError> {

    guard case let .project(projectParam, .liveStream(eventId), refTag) = nav else { return .empty }

    return SignalProducer.zip(
      AppEnvironment.current.apiService.fetchProject(param: projectParam)
        .demoteErrors(),

      AppEnvironment.current.liveStreamService
        .fetchEvent(eventId: eventId,
                    uid: AppEnvironment.current.currentUser?.id,
                    liveAuthToken: AppEnvironment.current.currentUser?.liveAuthToken)
        .demoteErrors()
      )
      .map { project, liveStreamEvent -> (Project, LiveStreamEvent, RefTag?)? in
        return (project, liveStreamEvent, refTag)
      }
      .skipNil()
}

private func visitorCookies() -> [HTTPCookie] {

  let uuidString = (AppEnvironment.current.device.identifierForVendor ?? UUID()).uuidString

  return [HTTPCookie?].init(arrayLiteral:
    HTTPCookie(
      properties: [
        .name: "vis",
        .value: uuidString,
        .domain: AppEnvironment.current.apiService.serverConfig.webBaseUrl.host as Any,
        .path: "/",
        .version: 0,
        .expires: Date.distantFuture,
        .secure: true,
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
        .secure: true,
        ]
    )
  )
  .compact()
}

@available(iOS 10.0, *)
private func authStatusType(for status: UNAuthorizationStatus) -> NotificationAuthorizationStatus {
  switch status {
  case .authorized: return .authorized
  case .denied: return .denied
  case .notDetermined: return .notDetermined
  }
}
