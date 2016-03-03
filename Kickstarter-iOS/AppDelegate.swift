import UIKit
import HockeySDK
import protocol Library.HockeyManagerType
import struct Library.AppEnvironment
import Prelude

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    turnOnHockeyApp()

    return true
  }

  private func turnOnHockeyApp() {
    let hockeyManager = AppEnvironment.current.hockeyManager

    guard let identifier = hockeyManager.appIdentifier()
      where identifier.characters.count > 0 else {
      print("HockeyApp not initialized: could not find appIdentifier. This most likely means that " +
        "the hockeyapp.config file could not be found.")
      return
    }

    hockeyManager.configureWithIdentifier(identifier)
    hockeyManager.startManager()
  }
}
