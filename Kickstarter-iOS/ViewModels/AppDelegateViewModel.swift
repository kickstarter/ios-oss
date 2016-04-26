import Library
import Foundation
import ReactiveCocoa
import Result
import Models
import KsApi

internal protocol AppDelegateViewModelInputs {
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

internal protocol AppDelegateViewModelOutputs {
  /// Emits a fresh user to be updated in the app environment.
  var updateCurrentUserInEnvironment: Signal<User, NoError> { get }

  // Emits a config value that should be updated in the environment.
  var updateConfigInEnvironment: Signal<Config, NoError> { get }

  /// Emits an NSNotification that should be immediately posted.
  var postNotification: Signal<NSNotification, NoError> { get }

  /// Return this value in the delegate's
  var facebookOpenURLReturnValue: MutableProperty<Bool> { get }
}

internal protocol AppDelegateViewModelType {
  var inputs: AppDelegateViewModelInputs { get }
  var outputs: AppDelegateViewModelOutputs { get }
}

internal final class AppDelegateViewModel: AppDelegateViewModelType, AppDelegateViewModelInputs,
AppDelegateViewModelOutputs {

  // MARK: AppDelegateViewModelType

  internal var inputs: AppDelegateViewModelInputs { return self }
  internal var outputs: AppDelegateViewModelOutputs { return self }

  // MARK: AppDelegateViewModelInputs

  private typealias ApplicationWithOptions = (application: UIApplication, options: [NSObject:AnyObject]?)
  private let applicationDidFinishLaunchingProperty = MutableProperty<ApplicationWithOptions?>(nil)
  func applicationDidFinishLaunching(application application: UIApplication,
                                                 launchOptions: [NSObject : AnyObject]?) {
    self.applicationDidFinishLaunchingProperty.value = (application, launchOptions)
  }
  private let applicationWillEnterForegroundProperty = MutableProperty(())
  internal func applicationWillEnterForeground() {
    self.applicationWillEnterForegroundProperty.value = ()
  }
  private let applicationDidEnterBackgroundProperty = MutableProperty(())
  internal func applicationDidEnterBackground() {
    self.applicationDidEnterBackgroundProperty.value = ()
  }
  private let currentUserUpdatedInEnvironmentProperty = MutableProperty(())
  internal func currentUserUpdatedInEnvironment() {
    self.currentUserUpdatedInEnvironmentProperty.value = ()
  }
  private let configUpdatedInEnvironmentProperty = MutableProperty()
  internal func configUpdatedInEnvironment() {
    self.configUpdatedInEnvironmentProperty.value = ()
  }
  private typealias ApplicationOpenUrl = (
    application: UIApplication,
    url: NSURL,
    sourceApplication: String?,
    annotation: AnyObject
  )
  private let applicationOpenUrlProperty = MutableProperty<ApplicationOpenUrl?>(nil)
  func applicationOpenUrl(application application: UIApplication,
                                      url: NSURL,
                                      sourceApplication: String?,
                                      annotation: AnyObject) {
    self.applicationOpenUrlProperty.value = (application, url, sourceApplication, annotation)
  }

  // MARK: AppDelegateViewModelOutputs

  internal let updateCurrentUserInEnvironment: Signal<User, NoError>
  internal let postNotification: Signal<NSNotification, NoError>
  internal let updateConfigInEnvironment: Signal<Config, NoError>
  internal let facebookOpenURLReturnValue = MutableProperty(false)

  internal init() {

    self.updateCurrentUserInEnvironment = Signal.merge([
        self.applicationWillEnterForegroundProperty.signal,
        self.applicationDidFinishLaunchingProperty.signal.ignoreValues()
      ])
      .filter { _ in AppEnvironment.current.apiService.isAuthenticated }
      .switchMap { _ in AppEnvironment.current.apiService.fetchUserSelf().demoteErrors() }

    self.updateConfigInEnvironment = Signal.merge([
      self.applicationWillEnterForegroundProperty.signal,
      self.applicationDidFinishLaunchingProperty.signal.ignoreValues()
      ])
      .switchMap { AppEnvironment.current.apiService.fetchConfig().demoteErrors() }

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
}

private func startHockeyManager(hockeyManager: HockeyManagerType) {
  guard let identifier = hockeyManager.appIdentifier()
    where !identifier.characters.isEmpty else {
      print("HockeyApp not initialized: could not find appIdentifier. This most likely means that " +
        "the hockeyapp.config file could not be found.")
      return
  }

  hockeyManager.configureWithIdentifier(identifier)
  hockeyManager.startManager()
  hockeyManager.autoSendReports()
}
