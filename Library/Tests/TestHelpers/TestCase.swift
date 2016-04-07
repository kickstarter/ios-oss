import XCTest
import AVFoundation
import ReactiveCocoa
@testable import Library
@testable import KsApi_TestHelpers

internal class TestCase: XCTestCase {
  internal let cookieStorage = MockCookieStorage()
  internal let hockeyManager = MockHockeyManager()
  internal let scheduler = TestScheduler()
  internal let trackingClient = MockTrackingClient()

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(
      apiService: MockService(),
      apiThrottleInterval: 1.0,
      assetImageGeneratorType: AVAssetImageGenerator.self,
      cookieStorage: self.cookieStorage,
      countryCode: "US",
      currentUser: nil,
      debounceInterval: 1.0,
      hockeyManager: self.hockeyManager,
      koala: Koala(client: self.trackingClient, loggedInUser: nil),
      language: .en,
      launchedCountries: .init(),
      locale: .currentLocale(),
      mainBundle: MockBundle(),
      scheduler: self.scheduler,
      timeZone: NSTimeZone(name: "GMT")!,
      ubiquitousStore: MockKeyValueStore(),
      userDefaults: MockKeyValueStore()
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }
}
