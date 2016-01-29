import UIKit
import KsApi

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  override init() {
    AppEnvironment.pushEnvironment(
      apiService: Service(
        serverConfig: ServerConfig.production,
        oauthToken: OauthToken(token: "6b02b5b59bfdf8111cdc97784b828f33b2b45dc4"),
        language: Language.de.rawValue
      ),
      language: .de,
      locale: NSLocale(localeIdentifier: "de")
    )

//    AppEnvironment.pushEnvironment(
//      apiService: MockService(),
//      countryCode: "US"
//    )
  }

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    return true
  }
}
