import AVFoundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveSwift
import XCTest

internal class TestCase: XCTestCase {
  internal static let interval = DispatchTimeInterval.milliseconds(1)

  internal let apiService = MockService()
  internal let appTrackingTransparency: AppTrackingTransparencyType = MockAppTrackingTransparency()
  internal let cache = KSCache()
  internal let config = Config.config
  internal let cookieStorage = MockCookieStorage()
  internal let coreTelephonyNetworkInfo = MockCoreTelephonyNetworkInfo()
  internal let dateType = MockDate.self

  /// Dynamically resolves the test bundle identifier based on the current test target.
  /// This approach allows us to load resources like Colors (e.g. `AdaptiveColors`) and Images
  /// correctly in Unit Tests by ensuring the `mainBundle` points to the right asset bundle.
  /// This is especially useful when tests are executed from different targets (e.g. `Kickstarter-Framework-iOSTests`, `Library-iOS`),
  /// allowing consistent resolution of asset resources during testing.
  internal lazy var mainBundle: MockBundle = {
    let bundle = Bundle(for: Self.self)
    return MockBundle(bundleIdentifier: bundle.identifier)
  }()

  internal let remoteConfigClient = MockRemoteConfigClient()
  internal let reachability = MutableProperty(Reachability.wifi)
  internal let scheduler = TestScheduler(startDate: MockDate().date)
  internal let segmentTrackingClient = MockTrackingClient()
  internal let ubiquitousStore = MockKeyValueStore()
  internal let userDefaults = MockKeyValueStore()
  internal let uuidType = MockUUID.self
  internal let colorResolver = MockColorResolver()

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
      appTrackingTransparency: self.appTrackingTransparency,
      assetImageGeneratorType: AVAssetImageGenerator.self,
      cache: self.cache,
      calendar: calendar,
      colorResolver: self.colorResolver,
      config: self.config,
      cookieStorage: self.cookieStorage,
      coreTelephonyNetworkInfo: self.coreTelephonyNetworkInfo,
      countryCode: "US",
      currentUser: nil,
      dateType: self.dateType,
      debounceInterval: .seconds(0),
      device: MockDevice(),
      isVoiceOverRunning: { false },
      ksrAnalytics: KSRAnalytics(
        loggedInUser: nil,
        segmentClient: self.segmentTrackingClient,
        appTrackingTransparency: self.appTrackingTransparency
      ),
      language: .en,
      launchedCountries: .init(),
      locale: .init(identifier: "en_US"),
      mainBundle: self.mainBundle,
      pushRegistrationType: MockPushRegistration.self,
      reachability: self.reachability.producer,
      remoteConfigClient: self.remoteConfigClient,
      scheduler: self.scheduler,
      ubiquitousStore: self.ubiquitousStore,
      userDefaults: self.userDefaults,
      uuidType: self.uuidType
    )

    self.preferredSimulatorCheck()
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  /// Fulfills an expectation on the next run loop to allow a layout pass when required in some tests.
  internal func allowLayoutPass() {
    let exp = self.expectation(description: "layoutPass")
    DispatchQueue.main.async {
      exp.fulfill()
    }

    waitForExpectations(timeout: 0.01)
  }

  internal func preferredSimulatorCheck() {
    let deviceName = ProcessInfo().environment["SIMULATOR_VERSION_INFO"]
    let iOSVersion = ProcessInfo().environment["SIMULATOR_RUNTIME_VERSION"]

    // Keep this check in sync with the device specified in `.cicleci/config.yml` and `Makefile`.
    guard deviceName!.localizedStandardContains("iPhone SE (3rd generation)"), iOSVersion == "17.5" else {
      fatalError("Please only test and record screenshots on an iPhone SE simulator running iOS 17.5")
    }
  }
}
