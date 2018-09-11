// swiftlint:disable force_unwrapping
import AVFoundation
import FBSnapshotTestCase
import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import LiveStream

internal class TestCase: FBSnapshotTestCase {
  internal static let interval = DispatchTimeInterval.milliseconds(1)

  internal let apiService = MockService()
  internal let cache = KSCache()
  internal let config = Config.config
  internal let cookieStorage = MockCookieStorage()
  internal let dateType = MockDate.self
  internal let facebookAppDelegate = MockFacebookAppDelegate()
  internal let liveStreamService = MockLiveStreamService()
  internal let mainBundle = MockBundle()
  internal let reachability = MutableProperty(Reachability.wifi)
  internal let scheduler = TestScheduler(startDate: MockDate().date)
  internal let trackingClient = MockTrackingClient()
  internal let ubiquitousStore = MockKeyValueStore()
  internal let userDefaults = MockKeyValueStore()

  override func setUp() {
    super.setUp()
    UIView.doBadSwizzleStuff()
    UIViewController.doBadSwizzleStuff()

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    let isVoiceOverRunning = { false }
    AppEnvironment.pushEnvironment(
      apiService: self.apiService,
      apiDelayInterval: .seconds(0),
      assetImageGeneratorType: AVAssetImageGenerator.self,
      cache: self.cache,
      calendar: calendar,
      config: self.config,
      cookieStorage: self.cookieStorage,
      countryCode: "US",
      currentUser: nil,
      dateType: dateType,
      debounceInterval: .seconds(0),
      device: MockDevice(),
      facebookAppDelegate: self.facebookAppDelegate,
      isVoiceOverRunning: isVoiceOverRunning,
      koala: Koala(client: self.trackingClient, loggedInUser: nil),
      language: .en,
      launchedCountries: .init(),
      liveStreamService: self.liveStreamService,
      locale: .init(identifier: "en_US"),
      mainBundle: mainBundle,
      reachability: self.reachability.producer,
      scheduler: self.scheduler,
      ubiquitousStore: self.ubiquitousStore,
      userDefaults: self.userDefaults
    )
    self.recordMode = true
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }
}
