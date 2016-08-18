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

  /// Emits when a view controller should be presented.
  var presentViewController: Signal<UIViewController, NoError> { get }

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
        self.applicationDidFinishLaunchingProperty.signal.ignoreValues()
      ])
      .filter { _ in AppEnvironment.current.apiService.isAuthenticated }
      .switchMap { _ in AppEnvironment.current.apiService.fetchUserSelf().demoteErrors() }

    self.updateEnvironment = Signal.merge([
      self.applicationWillEnterForegroundProperty.signal,
      self.applicationDidFinishLaunchingProperty.signal.ignoreValues()
      ])
      .switchMap { AppEnvironment.current.apiService.fetchConfig().demoteErrors() }
      .map { config in
        (config, AppEnvironment.current.koala |> Koala.lens.config .~ config)
    }

    self.postNotification = self.currentUserUpdatedInEnvironmentProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.userUpdated, object: nil))

    self.applicationDidFinishLaunchingProperty.signal.ignoreNil()
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

    // Deep links

    let deepLink = openUrl
      .map { Navigation.match($0.url) }
      .ignoreNil()

    self.goToActivity = deepLink
      .filter { link in
        guard case .tab(.activity) = link else { return false }
        return true
      }
      .ignoreValues()

    self.goToSearch = deepLink
      .filter { link in
        guard case .tab(.search) = link else { return false }
        return true
      }
      .ignoreValues()

    self.goToLogin = deepLink
      .filter { link in
        guard case .tab(.login) = link else { return false }
        return true
      }
      .ignoreValues()

    self.goToProfile = deepLink
      .filter { link in
        guard case .tab(.me) = link else { return false }
        return true
      }
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
      .filter { _, subpage, _ in
        guard case .root = subpage else { return false }
        return true
      }
      .map { _, _, vcs in vcs }

    let projectCommentsLink = projectLink
      .filter { _, subpage, _ in
        guard case .comments = subpage else { return false }
        return true
      }
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
      .filter { _, _, subpage, _ in
        guard case .root = subpage else { return false }
        return true
      }
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

    self.applicationDidFinishLaunchingProperty.signal.ignoreValues()
      .mergeWith(self.applicationWillEnterForegroundProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackAppOpen() }

    self.applicationDidEnterBackgroundProperty.signal
      .observeNext { AppEnvironment.current.koala.trackAppClose() }
  }
  // swiftlint:enable function_body_length
  // swiftlint:enable cyclomatic_complexity

  public var inputs: AppDelegateViewModelInputs { return self }
  public var outputs: AppDelegateViewModelOutputs { return self }

  private typealias ApplicationWithOptions = (application: UIApplication, options: [NSObject:AnyObject]?)
  private let applicationDidFinishLaunchingProperty = MutableProperty<ApplicationWithOptions?>(nil)
  public func applicationDidFinishLaunching(application application: UIApplication,
                                                          launchOptions: [NSObject : AnyObject]?) {
    self.applicationDidFinishLaunchingProperty.value = (application, launchOptions)
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

  public let goToActivity: Signal<(), NoError>
  public let goToDashboard: Signal<Param, NoError>
  public let goToLogin: Signal<(), NoError>
  public let goToProfile: Signal<(), NoError>
  public let goToSearch: Signal<(), NoError>
  public let postNotification: Signal<NSNotification, NoError>
  public let presentViewController: Signal<UIViewController, NoError>
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
