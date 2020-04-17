import AVFoundation
import FBSnapshotTestCase
@testable import KsApi
@testable import Library
import Prelude
import ReactiveSwift
import XCTest

internal class TestCase: FBSnapshotTestCase {
  internal static let interval = DispatchTimeInterval.milliseconds(1)

  internal let apiService = MockService()
  internal let cache = KSCache()
  internal let config = Config.config
  internal let cookieStorage = MockCookieStorage()
  internal let coreTelephonyNetworkInfo = MockCoreTelephonyNetworkInfo()
  internal let dataLakeTrackingClient = MockTrackingClient()
  internal let dateType = MockDate.self
  internal let mainBundle = MockBundle()
  internal let optimizelyClient = MockOptimizelyClient()
  internal let reachability = MutableProperty(Reachability.wifi)
  internal let scheduler = TestScheduler(startDate: MockDate().date)
  internal let trackingClient = MockTrackingClient()
  internal let ubiquitousStore = MockKeyValueStore()
  internal let userDefaults = MockKeyValueStore()

  override var recordMode: Bool {
    willSet(newValue) {
      if newValue {
        preferredSimulatorCheck()
      }
    }
  }

  override func setUp() {
    super.setUp()

    UIView.doBadSwizzleStuff()
    UIViewController.doBadSwizzleStuff()

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    AppEnvironment.pushEnvironment(
      apiService: self.apiService,
      apiDelayInterval: .seconds(0),
      applePayCapabilities: MockApplePayCapabilities(),
      application: UIApplication.shared,
      assetImageGeneratorType: AVAssetImageGenerator.self,
      cache: self.cache,
      calendar: calendar,
      config: self.config,
      cookieStorage: self.cookieStorage,
      coreTelephonyNetworkInfo: self.coreTelephonyNetworkInfo,
      countryCode: "US",
      currentUser: nil,
      dateType: self.dateType,
      debounceInterval: .seconds(0),
      device: MockDevice(),
      isVoiceOverRunning: { false },
      koala: Koala(
        dataLakeClient: self.dataLakeTrackingClient,
        client: self.trackingClient,
        loggedInUser: nil
      ),
      language: .en,
      launchedCountries: .init(),
      locale: .init(identifier: "en_US"),
      mainBundle: self.mainBundle,
      optimizelyClient: self.optimizelyClient,
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

internal func preferredSimulatorCheck() {
  let supportedModels = ["iPhone10,1", "iPhone10,4"] // iPhone 8
  let modelKey = "SIMULATOR_MODEL_IDENTIFIER"

  guard #available(iOS 13.0, *), supportedModels.contains(ProcessInfo().environment[modelKey] ?? "") else {
    fatalError("Please only test and record screenshots on an iPhone 8 simulator running iOS 13")
  }
}
