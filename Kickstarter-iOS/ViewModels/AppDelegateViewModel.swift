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
  /// Emits a fresh user to be updated in the app environment.
  var updateCurrentUserInEnvironment: Signal<User, NoError> { get }

  // Emits a config value that should be updated in the environment.
  var updateEnvironment: Signal<(Config, Koala), NoError> { get }

  /// Emits an NSNotification that should be immediately posted.
  var postNotification: Signal<NSNotification, NoError> { get }

  /// Return this value in the delegate's
  var facebookOpenURLReturnValue: MutableProperty<Bool> { get }
}

public protocol AppDelegateViewModelType {
  var inputs: AppDelegateViewModelInputs { get }
  var outputs: AppDelegateViewModelOutputs { get }
}

public final class AppDelegateViewModel: AppDelegateViewModelType, AppDelegateViewModelInputs,
AppDelegateViewModelOutputs {

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

    self.applicationOpenUrlProperty.signal.ignoreNil()
      .observeNext {
        self.facebookOpenURLReturnValue.value = AppEnvironment.current.facebookAppDelegate.application(
          $0.application, openURL: $0.url, sourceApplication: $0.sourceApplication, annotation: $0.annotation)
    }

    self.applicationDidFinishLaunchingProperty.signal.ignoreValues()
      .mergeWith(self.applicationWillEnterForegroundProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackAppOpen() }

    self.applicationDidEnterBackgroundProperty.signal
      .observeNext { AppEnvironment.current.koala.trackAppClose() }
  }

  public var inputs: AppDelegateViewModelInputs { return self }
  public var outputs: AppDelegateViewModelOutputs { return self }

  private typealias ApplicationWithOptions = (application: UIApplication, options: [NSObject:AnyObject]?)
  private let applicationDidFinishLaunchingProperty = MutableProperty<ApplicationWithOptions?>(nil)
  public func applicationDidFinishLaunching(application application: UIApplication,
                                                          launchOptions: [NSObject : AnyObject]?) {
    self.applicationDidFinishLaunchingProperty.value = (application, launchOptions)
  }
  private let applicationWillEnterForegroundProperty = MutableProperty(())
  public func applicationWillEnterForeground() {
    self.applicationWillEnterForegroundProperty.value = ()
  }
  private let applicationDidEnterBackgroundProperty = MutableProperty(())
  public func applicationDidEnterBackground() {
    self.applicationDidEnterBackgroundProperty.value = ()
  }
  private let currentUserUpdatedInEnvironmentProperty = MutableProperty(())
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

  public let updateCurrentUserInEnvironment: Signal<User, NoError>
  public let postNotification: Signal<NSNotification, NoError>
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
