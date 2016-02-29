import UIKit
import KsApi
import Models
import ReactiveCocoa
import ReactiveExtensions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    Service.shared.fetchProjects(DiscoveryParams())
      .uncollect()
      .map { $0.name }
      .startWithNext { name in
        print(name)
    }

    return true
  }
}

