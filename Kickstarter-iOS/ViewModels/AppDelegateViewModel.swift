import struct Library.Environment
import struct Library.AppEnvironment
import protocol Library.HockeyManagerType
import class Foundation.NSObject
import class ReactiveCocoa.MutableProperty

internal protocol AppDelegateViewModelInputs {
  func applicationDidFinishLaunching(launchOptions launchOptions: [NSObject: AnyObject]?)
  func applicationWillEnterForeground()
  func applicationDidEnterBackground()
}

internal protocol AppDelegateViewModelType {
  var inputs: AppDelegateViewModelInputs { get }
}

internal final class AppDelegateViewModel: AppDelegateViewModelType, AppDelegateViewModelInputs {

  private let applicationDidFinishLaunchingProperty = MutableProperty<[NSObject:AnyObject]?>(nil)
  internal func applicationDidFinishLaunching(launchOptions launchOptions: [NSObject:AnyObject]?) {
    self.applicationDidFinishLaunchingProperty.value = launchOptions
  }

  private let applicationWillEnterForegroundProperty = MutableProperty<()>(())
  internal func applicationWillEnterForeground() {
    self.applicationWillEnterForegroundProperty.value = ()
  }

  private let applicationDidEnterBackgroundProperty = MutableProperty<()>(())
  internal func applicationDidEnterBackground() {
    self.applicationDidEnterBackgroundProperty.value = ()
  }

  internal var inputs: AppDelegateViewModelInputs { return self }

  internal init(env: Environment = AppEnvironment.current) {
    let koala = AppEnvironment.current.koala
    let hockeyManager = AppEnvironment.current.hockeyManager

    self.applicationDidFinishLaunchingProperty.signal
      .take(1)
      .map { _ in hockeyManager }
      .observeNext(AppDelegateViewModel.startHockeyManager)

    self.applicationDidFinishLaunchingProperty.signal.ignoreValues()
      .mergeWith(self.applicationWillEnterForegroundProperty.signal)
      .observeNext(koala.trackAppOpen)

    self.applicationDidEnterBackgroundProperty.signal
      .observeNext(koala.trackAppClose)
  }

  private static func startHockeyManager(hockeyManager: HockeyManagerType) {
    guard let identifier = hockeyManager.appIdentifier()
      where identifier.characters.count > 0 else {
        print("HockeyApp not initialized: could not find appIdentifier. This most likely means that " +
          "the hockeyapp.config file could not be found.")
        return
    }

    hockeyManager.configureWithIdentifier(identifier)
    hockeyManager.startManager()
    hockeyManager.autoSendReports()
  }
}
