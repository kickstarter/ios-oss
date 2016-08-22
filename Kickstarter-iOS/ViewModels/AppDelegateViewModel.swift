// swiftlint:disable file_length
import Argo
import KsApi
import Library
import Prelude
import ReactiveCocoa
import Result

public protocol AppDelegateViewModelInputs {
  /// Call when the application finishes launching.
  func applicationDidFinishLaunching(application application: UIApplication,
                                                 launchOptions: [NSObject: AnyObject]?)

  /// Call when the application will enter foreground.
  func applicationWillEnterForeground()

  /// Call when the application enters background.
  func applicationDidEnterBackground()

  /// Call to open a url that was sent to the app
  func applicationOpenUrl(application application: UIApplication, url: NSURL, sourceApplication: String?,
                                      annotation: AnyObject)

  /// Call after having invoked AppEnvironemt.updateCurrentUser with a fresh user.
  func currentUserUpdatedInEnvironment()

  /// Call when the app delegate receives a remote notification.
  func didReceive(remoteNotification notification: AnyObject, applicationIsActive: Bool)

  /// Call when the app delegate gets notice of a successful notification registration.
  func didRegisterForRemoteNotifications(withDeviceTokenData data: NSData)

  /// Call when the user taps "OK" from the notification alert.
  func openRemoteNotificationTappedOk()

  /// Call when the controller has received a user session ended notification.
  func userSessionEnded()

  /// Call when the controller has received a user session started notification.
  func userSessionStarted()
}

public protocol AppDelegateViewModelOutputs {
  /// Return this value in the delegate's.
  var facebookOpenURLReturnValue: MutableProperty<Bool> { get }

  /// Emits when the root view controller should navigate to activity.
  var goToActivity: Signal<(), NoError> { get }

  /// Emits when the root view controller should navigate to the creator dashboard.
  var goToDashboard: Signal<Param, NoError> { get }

  /// Emits when the root view controller should navigate to the login screen.
  var goToLogin: Signal<(), NoError> { get }

  /// Emits when the root view controller should navigate to the user's profile.
  var goToProfile: Signal<(), NoError> { get }

  /// Emits when the root view controller should navigate to search.
  var goToSearch: Signal<(), NoError> { get }

  /// Emits an NSNotification that should be immediately posted.
  var postNotification: Signal<NSNotification, NoError> { get }

  /// Emits a message when a remote notification alert should be displayed to the user.
  var presentRemoteNotificationAlert: Signal<String, NoError> { get }

  /// Emits when a view controller should be presented.
  var presentViewController: Signal<UIViewController, NoError> { get }

  /// Emits when the push token has been successfully registered on the server.
  var pushTokenSuccessfullyRegistered: Signal<(), NoError> { get }

  /// Emits when we should attempt registering the user for notifications.
  var registerUserNotificationSettings: Signal<(), NoError> { get }

  /// Emits when we should unregister the user from notifications.
  var unregisterForRemoteNotifications: Signal<(), NoError> { get }

  /// Emits a fresh user to be updated in the app environment.
  var updateCurrentUserInEnvironment: Signal<User, NoError> { get }

  /// Emits a config value that should be updated in the environment.
  var updateEnvironment: Signal<(Config, Koala), NoError> { get }
}

public protocol AppDelegateViewModelType {
  var inputs: AppDelegateViewModelInputs { get }
  var outputs: AppDelegateViewModelOutputs { get }
}

public final class AppDelegateViewModel: AppDelegateViewModelType, AppDelegateViewModelInputs,
AppDelegateViewModelOutputs {

  // swiftlint:disable function_body_length
  // swiftlint:disable cyclomatic_complexity
  public init() {

    self.updateCurrentUserInEnvironment = Signal.merge([
        self.applicationWillEnterForegroundProperty.signal,
        self.applicationLaunchOptionsProperty.signal.ignoreValues()
      ])
      .filter { _ in AppEnvironment.current.apiService.isAuthenticated }
      .switchMap { _ in AppEnvironment.current.apiService.fetchUserSelf().demoteErrors() }

    self.updateEnvironment = Signal.merge([
      self.applicationWillEnterForegroundProperty.signal,
      self.applicationLaunchOptionsProperty.signal.ignoreValues()
      ])
      .switchMap { AppEnvironment.current.apiService.fetchConfig().demoteErrors() }
      .map { config in
        (config, AppEnvironment.current.koala |> Koala.lens.config .~ config)
    }

    self.postNotification = self.currentUserUpdatedInEnvironmentProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.userUpdated, object: nil))

    self.applicationLaunchOptionsProperty.signal.ignoreNil()
      .take(1)
      .observeNext { appOptions in
        AppEnvironment.current.facebookAppDelegate.application(
          appOptions.application,
          didFinishLaunchingWithOptions: appOptions.options
        )
        startHockeyManager(AppEnvironment.current.hockeyManager)
    }

    let openUrl = self.applicationOpenUrlProperty.signal.ignoreNil()

    self.facebookOpenURLReturnValue <~ openUrl.map {
      AppEnvironment.current.facebookAppDelegate.application(
        $0.application, openURL: $0.url, sourceApplication: $0.sourceApplication, annotation: $0.annotation)
    }

    // Push notifications

    self.registerUserNotificationSettings = Signal.merge(
      self.applicationWillEnterForegroundProperty.signal,
      self.applicationLaunchOptionsProperty.signal.ignoreValues(),
      self.userSessionStartedProperty.signal
      )
      .filter { AppEnvironment.current.currentUser != nil }

    self.unregisterForRemoteNotifications = self.userSessionEndedProperty.signal

    self.pushTokenSuccessfullyRegistered = self.deviceTokenDataProperty.signal
      .map(deviceToken(fromData:))
      .switchMap {
        AppEnvironment.current.apiService.register(pushToken: $0)
          .demoteErrors()
      }
      .ignoreValues()

    let remoteNotificationFromLaunch = self.applicationLaunchOptionsProperty.signal.ignoreNil()
      .map { _, options in options?[UIApplicationLaunchOptionsRemoteNotificationKey] }
      .ignoreNil()

    let localNotificationFromLaunch = self.applicationLaunchOptionsProperty.signal.ignoreNil()
      .map { _, options in options?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification }
      .map { $0?.userInfo as? AnyObject }
      .ignoreNil()

    let notificationAndIsActive = Signal.merge(
      self.remoteNotificationAndIsActiveProperty.signal.ignoreNil(),
      remoteNotificationFromLaunch.map { ($0, false) },
      localNotificationFromLaunch.map { ($0, false) }
    )

    let pushEnvelopeAndIsActive = notificationAndIsActive
      .flatMap { (notification, isActive) -> SignalProducer<(PushEnvelope, Bool), NoError> in
        guard let envelope = (decode(notification) as Decoded<PushEnvelope>).value else { return .empty }
        return SignalProducer(value: (envelope, isActive))
    }

    self.presentRemoteNotificationAlert = pushEnvelopeAndIsActive
      .filter { _, isActive in isActive }
      .map { env, _ in env.aps.alert }

    let explicitlyOpenedNotification = pushEnvelopeAndIsActive
      .takeWhen(self.openRemoteNotificationTappedOkProperty.signal)

    let pushEnvelope = Signal.merge(
      pushEnvelopeAndIsActive.filter { _, isActive in !isActive },
      explicitlyOpenedNotification
      )
      .map(first)

    let deepLinkFromNotification = pushEnvelope
      .map(navigation(fromPushEnvelope:))

    // Deep links

    let deepLinkFromOpenedUrl = openUrl.map { Navigation.match($0.url) }

    let deepLink = Signal.merge(
      deepLinkFromOpenedUrl,
      deepLinkFromNotification
      )
      .ignoreNil()

    self.goToActivity = deepLink
      .filter { $0 == .tab(.activity) }
      .ignoreValues()

    self.goToSearch = deepLink
      .filter { $0 == .tab(.search) }
      .ignoreValues()

    self.goToLogin = deepLink
      .filter { $0 == .tab(.login) }
      .ignoreValues()

    self.goToProfile = deepLink
      .filter { $0 == .tab(.me) }
      .ignoreValues()

    let projectLink = deepLink
      .map { link -> (Param, Navigation.Project, RefTag?)? in
        guard case let .project(param, subpage, refTag) = link else { return nil }
        return (param, subpage, refTag)
      }
      .ignoreNil()
      .switchMap { param, subpage, refTag in
        AppEnvironment.current.apiService.fetchProject(param: param)
          .demoteErrors()
          .observeForUI()
          .map { project -> (Project, Navigation.Project, [UIViewController]) in
            (project, subpage,
              [ProjectMagazineViewController.configuredWith(projectOrParam: .left(project), refTag: refTag)])
        }
    }

    self.goToDashboard = deepLink
      .map { link -> Param? in
        guard case let .tab(.dashboard(param)) = link else { return nil }
        return param
      }
      .ignoreNil()

    let projectRootLink = projectLink
      .filter { _, subpage, _ in subpage == .root }
      .map { _, _, vcs in vcs }

    let projectCommentsLink = projectLink
      .filter { _, subpage, _ in subpage == .comments }
      .map { project, _, vcs in vcs + [CommentsViewController.configuredWith(project: project, update: nil)] }

    let updateLink = projectLink
      .map { project, subpage, vcs -> (Project, Int, Navigation.Project.Update, [UIViewController])? in
        guard case let .update(id, updateSubpage) = subpage else { return nil }
        return (project, id, updateSubpage, vcs)
      }
      .ignoreNil()
      .switchMap { project, id, updateSubpage, vcs in
        AppEnvironment.current.apiService.fetchUpdate(updateId: id, projectParam: .id(project.id))
          .demoteErrors()
          .observeForUI()
          .map { update -> (Project, Update, Navigation.Project.Update, [UIViewController]) in
            (project, update, updateSubpage,
              vcs + [UpdateViewController.configuredWith(project: project, update: update)])
        }
    }

    let updateRootLink = updateLink
      .filter { _, _, subpage, _ in subpage == .root }
      .map { _, _, _, vcs in vcs }

    let updateCommentsLink = updateLink
      .observeForUI()
      .map { project, update, subpage, vcs -> [UIViewController]? in
        guard case .comments = subpage else { return nil }
        return vcs + [CommentsViewController.configuredWith(project: project, update: update)]
      }
      .ignoreNil()

    self.presentViewController = Signal
      .merge(
        projectRootLink,
        projectCommentsLink,
        updateRootLink,
        updateCommentsLink
      )
      .map { UINavigationController() |> UINavigationController.lens.viewControllers .~ $0 }

    // Koala

    Signal.merge(
      self.applicationLaunchOptionsProperty.signal.ignoreValues(),
      self.applicationWillEnterForegroundProperty.signal
      )
      .observeNext { AppEnvironment.current.koala.trackAppOpen() }

    self.applicationDidEnterBackgroundProperty.signal
      .observeNext { AppEnvironment.current.koala.trackAppClose() }

    deepLinkFromNotification
      .observeNext { _ in AppEnvironment.current.koala.trackNotificationOpened() }
  }
  // swiftlint:enable function_body_length
  // swiftlint:enable cyclomatic_complexity

  public var inputs: AppDelegateViewModelInputs { return self }
  public var outputs: AppDelegateViewModelOutputs { return self }

  private typealias ApplicationWithOptions = (application: UIApplication, options: [NSObject:AnyObject]?)
  private let applicationLaunchOptionsProperty = MutableProperty<ApplicationWithOptions?>(nil)
  public func applicationDidFinishLaunching(application application: UIApplication,
                                                          launchOptions: [NSObject : AnyObject]?) {
    self.applicationLaunchOptionsProperty.value = (application, launchOptions)
  }

  private let applicationWillEnterForegroundProperty = MutableProperty()
  public func applicationWillEnterForeground() {
    self.applicationWillEnterForegroundProperty.value = ()
  }

  private let applicationDidEnterBackgroundProperty = MutableProperty()
  public func applicationDidEnterBackground() {
    self.applicationDidEnterBackgroundProperty.value = ()
  }

  private let currentUserUpdatedInEnvironmentProperty = MutableProperty()
  public func currentUserUpdatedInEnvironment() {
    self.currentUserUpdatedInEnvironmentProperty.value = ()
  }

  private let configUpdatedInEnvironmentProperty = MutableProperty()
  public func configUpdatedInEnvironment() {
    self.configUpdatedInEnvironmentProperty.value = ()
  }

  private let remoteNotificationAndIsActiveProperty = MutableProperty<(AnyObject, Bool)?>(nil)
  public func didReceive(remoteNotification notification: AnyObject, applicationIsActive: Bool) {
    self.remoteNotificationAndIsActiveProperty.value = (notification, applicationIsActive)
  }

  private let deviceTokenDataProperty = MutableProperty(NSData())
  public func didRegisterForRemoteNotifications(withDeviceTokenData data: NSData) {
    self.deviceTokenDataProperty.value = data
  }

  private typealias ApplicationOpenUrl = (
    application: UIApplication,
    url: NSURL,
    sourceApplication: String?,
    annotation: AnyObject
  )
  private let applicationOpenUrlProperty = MutableProperty<ApplicationOpenUrl?>(nil)
  public func applicationOpenUrl(application application: UIApplication,
                                               url: NSURL,
                                               sourceApplication: String?,
                                               annotation: AnyObject) {
    self.applicationOpenUrlProperty.value = (application, url, sourceApplication, annotation)
  }

  private let openRemoteNotificationTappedOkProperty = MutableProperty()
  public func openRemoteNotificationTappedOk() {
    self.openRemoteNotificationTappedOkProperty.value = ()
  }

  private let userSessionEndedProperty = MutableProperty()
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  private let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  public let goToActivity: Signal<(), NoError>
  public let goToDashboard: Signal<Param, NoError>
  public let goToLogin: Signal<(), NoError>
  public let goToProfile: Signal<(), NoError>
  public let goToSearch: Signal<(), NoError>
  public let postNotification: Signal<NSNotification, NoError>
  public let presentRemoteNotificationAlert: Signal<String, NoError>
  public let presentViewController: Signal<UIViewController, NoError>
  public let pushTokenSuccessfullyRegistered: Signal<(), NoError>
  public let registerUserNotificationSettings: Signal<(), NoError>
  public let unregisterForRemoteNotifications: Signal<(), NoError>
  public let updateCurrentUserInEnvironment: Signal<User, NoError>
  public let updateEnvironment: Signal<(Config, Koala), NoError>
  public let facebookOpenURLReturnValue = MutableProperty(false)
}

private func startHockeyManager(hockeyManager: HockeyManagerType) {
  guard let identifier = hockeyManager.appIdentifier()
    where !identifier.isEmpty else {
      print("HockeyApp not initialized: could not find appIdentifier. This most likely means that " +
        "the hockeyapp.config file could not be found.")
      return
  }

  hockeyManager.configureWithIdentifier(identifier)
  hockeyManager.startManager()
  hockeyManager.autoSendReports()
}

private func deviceToken(fromData data: NSData) -> String {

  return UnsafeBufferPointer<UInt8>(start: UnsafePointer(data.bytes), count: data.length)
    .map { String(format: "%02hhx", $0) }
    .joinWithSeparator("")
}

// swiftlint:disable cyclomatic_complexity
private func navigation(fromPushEnvelope envelope: PushEnvelope) -> Navigation? {

  if let activity = envelope.activity {
    switch activity.category {
    case .backing, .failure, .launch, .success, .cancellation, .suspension:
      guard let projectId = activity.projectId else { return nil }
      if envelope.forCreator == true {
        return .tab(.dashboard(project: .id(projectId)))
      }
      return .project(.id(projectId), .root, refTag: .push)

    case .update:
      guard let projectId = activity.projectId, updateId = activity.updateId else { return nil }
      return .project(.id(projectId), .update(updateId, .root), refTag: .push)

    case .commentPost:
      guard let projectId = activity.projectId, updateId = activity.updateId else { return nil }
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
    if envelope.forCreator == true {
      return .tab(.dashboard(project: .id(project.id)))
    }
    return .project(.id(project.id), .root, refTag: .push)
  }

  if let _ = envelope.message {
    // todo
    if envelope.forCreator == true { } else { }
  }

  if let survey = envelope.survey {
    return .project(.id(survey.projectId), .survey(survey.id), refTag: .push)
  }

  return nil
}
// swiftlint:enable cyclomatic_complexity
