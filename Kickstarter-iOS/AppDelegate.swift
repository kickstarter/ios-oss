import class UIKit.UIResponder
import class UIKit.UIWindow
import class UIKit.UIApplication
import protocol UIKit.UIApplicationDelegate
import protocol Library.HockeyManagerType
import struct Library.AppEnvironment
import struct KsApi.Service
import struct KsApi.ServerConfig
import struct KsApi.OauthToken
import enum Library.Language
import class Foundation.NSLocale
import class Foundation.NSObject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  let viewModel: AppDelegateViewModelType = AppDelegateViewModel()

  override init() {
    AppEnvironment.pushEnvironment(
      apiService: Service(
        serverConfig: ServerConfig.production,
        oauthToken: OauthToken(token: "6b02b5b59bfdf8111cdc97784b828f33b2b45dc4"),
        language: Language.en.rawValue
      ),
      language: .en,
      locale: NSLocale(localeIdentifier: "en")
    )

//    AppEnvironment.pushEnvironment(
//      apiService: MockService(),
//      countryCode: "US"
//    )
  }

  func application(application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

      viewModel.inputs.applicationDidFinishLaunching(launchOptions: launchOptions)

      return true
  }

  func applicationWillEnterForeground(application: UIApplication) {
    self.viewModel.inputs.applicationWillEnterForeground()
  }

  func applicationDidEnterBackground(application: UIApplication) {
    self.viewModel.inputs.applicationDidEnterBackground()
  }
}
