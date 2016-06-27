import XCTest
import AVFoundation
import ReactiveCocoa
@testable import KsApi
@testable import Library

internal class TestCase: XCTestCase {
  internal static let interval = 0.001

  internal let apiService = MockService()
  internal let cache = MockCache()
  internal let config = Config.config
  internal let cookieStorage = MockCookieStorage()
  internal let facebookAppDelegate = MockFacebookAppDelegate()
  internal let hockeyManager = MockHockeyManager()
  internal let mainBundle = MockBundle()
  internal let scheduler = TestScheduler()
  internal let trackingClient = MockTrackingClient()
  internal let userDefaults = MockKeyValueStore()

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(
      apiService: self.apiService,
      apiDelayInterval: 0.0,
      assetImageGeneratorType: AVAssetImageGenerator.self,
      cache: self.cache,
      config: self.config,
      cookieStorage: self.cookieStorage,
      countryCode: "US",
      currentUser: nil,
      debounceInterval: 0.0,
      facebookAppDelegate: self.facebookAppDelegate,
      hockeyManager: self.hockeyManager,
      koala: Koala(client: self.trackingClient, loggedInUser: nil),
      language: .en,
      launchedCountries: .init(),
      locale: .currentLocale(),
      mainBundle: mainBundle,
      scheduler: self.scheduler,
      timeZone: NSTimeZone(name: "GMT")!,
      ubiquitousStore: MockKeyValueStore(),
      userDefaults: self.userDefaults
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }
}
