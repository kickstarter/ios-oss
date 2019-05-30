import AVFoundation
import FBSnapshotTestCase
import Prelude
import ReactiveSwift
import XCTest
@testable import KsApi
@testable import Library

internal class TestCase: FBSnapshotTestCase {
  internal static let interval = DispatchTimeInterval.milliseconds(1)

  internal let apiService = MockService()
  internal let cache = KSCache()
  internal let config = Config.config
  internal let cookieStorage = MockCookieStorage()
  internal let dateType = MockDate.self
  internal let facebookAppDelegate = MockFacebookAppDelegate()
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
    // swiftlint:disable:next force_unwrapping
    calendar.timeZone = TimeZone(identifier: "GMT")!

    let isVoiceOverRunning = { false }
    let isOSVersionAvailable: (Double) -> Bool = { _ in true }
    AppEnvironment.pushEnvironment(
      apiService: self.apiService,
      apiDelayInterval: .seconds(0),
      application: UIApplication.shared,
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
      isOSVersionAvailable: isOSVersionAvailable,
      isVoiceOverRunning: isVoiceOverRunning,
      koala: Koala(client: self.trackingClient, loggedInUser: nil),
      language: .en,
      launchedCountries: .init(),
      locale: .init(identifier: "en_US"),
      mainBundle: mainBundle,
      pushRegistrationType: MockPushRegistration.self,
      reachability: self.reachability.producer,
      scheduler: self.scheduler,
      ubiquitousStore: self.ubiquitousStore,
      userDefaults: self.userDefaults
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }
}
