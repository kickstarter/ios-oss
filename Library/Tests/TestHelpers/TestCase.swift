import XCTest
import AVFoundation
import ReactiveCocoa
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Library
@testable import KsApi_TestHelpers

internal class TestCase: XCTestCase {
  internal static let interval = 0.001

  internal let config = ConfigFactory.config
  internal let cookieStorage = MockCookieStorage()
  internal let facebookAppDelegate = MockFacebookAppDelegate()
  internal let hockeyManager = MockHockeyManager()
  internal let scheduler = TestScheduler()
  internal let trackingClient = MockTrackingClient()
  internal let userDefaults = MockKeyValueStore()

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(
      apiService: MockService(),
      apiDelayInterval: 0.0,
      assetImageGeneratorType: AVAssetImageGenerator.self,
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
      mainBundle: MockBundle(),
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
