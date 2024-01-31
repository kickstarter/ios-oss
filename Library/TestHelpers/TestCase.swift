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
  internal let mainBundle = MockBundle()
  internal let remoteConfigClient = MockRemoteConfigClient()
  internal let reachability = MutableProperty(Reachability.wifi)
  internal let scheduler = TestScheduler(startDate: MockDate().date)
  internal let segmentTrackingClient = MockTrackingClient()
  internal let ubiquitousStore = MockKeyValueStore()
  internal let userDefaults = MockKeyValueStore()
  internal let uuidType = MockUUID.self

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
    guard deviceName!.localizedStandardContains("iPhone SE (3rd generation)"), iOSVersion == "17.2" else {
      fatalError("Please only test and record screenshots on an iPhone SE simulator running iOS 17.2")
    }
  }
}
