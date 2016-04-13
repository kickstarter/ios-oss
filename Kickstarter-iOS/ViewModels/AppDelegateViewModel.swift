import Library
import Foundation
import ReactiveCocoa
import Result
import Models

internal protocol AppDelegateViewModelInputs {
  /// Call when the application finishes launching.
  func applicationDidFinishLaunching(launchOptions launchOptions: [NSObject: AnyObject]?)

  /// Call when the application will enter foreground.
  func applicationWillEnterForeground()

  /// Call when the application enters background.
  func applicationDidEnterBackground()

  /// Call after having invoked AppEnvironemt.updateCurrentUser with a fresh user.
  func currentUserUpdatedInEnvironment()
}

internal protocol AppDelegateViewModelOutputs {
  /// Emits a fresh user to be updated in the app environment.
  var updateCurrentUserInEnvironment: Signal<User, NoError> { get }

  /// Emits an NSNotification that should be immediately posted.
  var postNotification: Signal<NSNotification, NoError> { get }
}

internal protocol AppDelegateViewModelType {
  var inputs: AppDelegateViewModelInputs { get }
  var outputs: AppDelegateViewModelOutputs { get }
}

internal final class AppDelegateViewModel: AppDelegateViewModelType, AppDelegateViewModelInputs,
AppDelegateViewModelOutputs {

  private let applicationDidFinishLaunchingProperty = MutableProperty<[NSObject:AnyObject]?>(nil)
  internal func applicationDidFinishLaunching(launchOptions launchOptions: [NSObject:AnyObject]?) {
    self.applicationDidFinishLaunchingProperty.value = launchOptions
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

  internal let updateCurrentUserInEnvironment: Signal<User, NoError>
  internal let postNotification: Signal<NSNotification, NoError>

  internal var inputs: AppDelegateViewModelInputs { return self }
  internal var outputs: AppDelegateViewModelOutputs { return self }

  internal init(env: Environment = AppEnvironment.current) {

    self.updateCurrentUserInEnvironment = Signal.merge([
        self.applicationWillEnterForegroundProperty.signal,
        self.applicationDidFinishLaunchingProperty.signal.ignoreValues()
      ])
      .filter { _ in AppEnvironment.current.apiService.isAuthenticated }
      .switchMap { _ in AppEnvironment.current.apiService.fetchUserSelf().demoteErrors() }

    self.postNotification = self.currentUserUpdatedInEnvironmentProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.userUpdated, object: nil))

    self.applicationDidFinishLaunchingProperty.signal
      .take(1)
      .observeNext { _ in startHockeyManager(AppEnvironment.current.hockeyManager) }

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
