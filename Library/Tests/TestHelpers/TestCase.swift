import AVFoundation
import FBSnapshotTestCase
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library

internal class TestCase: FBSnapshotTestCase {
  internal static let interval = 0.001

  internal let apiService = MockService()
  internal let cache = MockCache()
  internal let config = Config.config
  internal let cookieStorage = MockCookieStorage()
  internal let facebookAppDelegate = MockFacebookAppDelegate()
  internal let mainBundle = MockBundle()
  internal let scheduler = TestScheduler()
  internal let trackingClient = MockTrackingClient()
  internal let ubiquitousStore = MockKeyValueStore()
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
      isVoiceOverRunning: { false },
      koala: Koala(client: self.trackingClient, loggedInUser: nil),
      language: .en,
      launchedCountries: .init(),
      locale: .currentLocale(),
      mainBundle: mainBundle,
      reachability: .init(value: .wifi),
      scheduler: self.scheduler,
      timeZone: NSTimeZone(name: "GMT")!,
      ubiquitousStore: self.ubiquitousStore,
      userDefaults: self.userDefaults
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }
}
