import AVFoundation
import iOSSnapshotTestCase
@testable import KsApi
@testable import Library
import Prelude
import ReactiveSwift
import SnapshotTesting
import XCTest

internal class TestCase: FBSnapshotTestCase {
  internal static let interval = DispatchTimeInterval.milliseconds(1)

  internal let apiService = MockService()
  internal let cache = KSCache()
  internal let config = Config.config
  internal let cookieStorage = MockCookieStorage()
  internal let coreTelephonyNetworkInfo = MockCoreTelephonyNetworkInfo()
  internal let dateType = MockDate.self
  internal let mainBundle = MockBundle()
  internal let optimizelyClient = MockOptimizelyClient()
  internal let reachability = MutableProperty(Reachability.wifi)
  internal let scheduler = TestScheduler(startDate: MockDate().date)
  internal let segmentTrackingClient = MockTrackingClient()
  internal let ubiquitousStore = MockKeyValueStore()
  internal let userDefaults = MockKeyValueStore()
  internal let uuidType = MockUUID.self

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
      ksrAnalytics: KSRAnalytics(
        loggedInUser: nil,
        segmentClient: self.segmentTrackingClient
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
      userDefaults: self.userDefaults,
      uuidType: self.uuidType
    )
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

  /// This function needs to be a holdover from switching to SnapshotTesting until we get our existing Snapshots re-recorded.
  /// We do not allow recording with this function. New recording use SnapshotTesting `assertSnapshot`.
  public func assertExistingSnapshot<Value, Format>(
    matching value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
  ) {
    let architectureTypeFolder =
      "_64/" // We've always recorded in 64-bit architecture, no need to check this dynamically

    let snapshotDirectory = ProcessInfo.processInfo
      .environment["FB_REFERENCE_IMAGE_DIR"]! + architectureTypeFolder + ProcessInfo.processInfo
      .environment["TEST_TARGET_NAME"]!.replacingOccurrences(of: "-", with: "_") + ".\(type(of: self))"
    let fileName = validFileName(testName) + "_" + name
    let fileNameWithScreenScale = addScreenScale(fileName)
    let fileNameWithExtension = fileNameWithScreenScale

    let failure = verifyExistingSnapshot(
      matching: try value(),
      as: snapshotting,
      named: fileNameWithExtension,
      record: false,
      snapshotDirectory: snapshotDirectory,
      timeout: timeout,
      file: file,
      testName: testName
    )
    guard let message = failure else { return }
    XCTFail(message, file: file, line: line)
  }
}

internal func preferredSimulatorCheck() {
  let supportedModels = ["iPhone10,1", "iPhone10,4"] // iPhone 8
  let modelKey = "SIMULATOR_MODEL_IDENTIFIER"

  guard #available(iOS 14.5, *), supportedModels.contains(ProcessInfo().environment[modelKey] ?? "") else {
    fatalError("Please only test and record screenshots on an iPhone 8 simulator running iOS 14.5")
  }
}

internal func validFileName(_ fileName: String) -> String {
  var invalidCharacters = CharacterSet()

  invalidCharacters.formUnion(.whitespaces)
  invalidCharacters.formUnion(.punctuationCharacters)

  let validComponents = fileName.components(separatedBy: invalidCharacters).filter { !$0.isEmpty }

  return validComponents.joined(separator: "_")
}

/// INFO: The `FBSnapshotTestCase` recordings defaulted to using `FBSnapshotTestCaseFileNameIncludeOptionScreenScale` so those recorded tests need to account for screenscale with `SnapshotTesting`
internal func addScreenScale(_ fileName: String) -> String {
  let screenScale = UIScreen.main.scale
  let fileNameWithScreenScale = fileName.appendingFormat("@%.fx", screenScale)

  return fileNameWithScreenScale
}

extension TestCase {
  public func verifyExistingSnapshot<Value, Format>(
    matching value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String,
    record recording: Bool = false,
    snapshotDirectory: String,
    timeout: TimeInterval = 5,
    file _: StaticString = #file,
    testName: String = #function,
    line _: UInt = #line
  )
    -> String? {
    let recording = recording || isRecording

    let snapshotDirectoryUrl = URL(fileURLWithPath: snapshotDirectory, isDirectory: true)
    let snapshotFileUrl = snapshotDirectoryUrl.appendingPathComponent(name)
      .appendingPathExtension(snapshotting.pathExtension ?? "")

    do {
      let fileManager = FileManager.default
      try fileManager.createDirectory(at: snapshotDirectoryUrl, withIntermediateDirectories: true)

      let tookSnapshot = XCTestExpectation(description: "Took snapshot")
      var optionalDiffable: Format?
      snapshotting.snapshot(try value()).run { b in
        optionalDiffable = b
        tookSnapshot.fulfill()
      }
      let result = XCTWaiter.wait(for: [tookSnapshot], timeout: timeout)
      switch result {
      case .completed:
        break
      case .timedOut:
        return """
        Exceeded timeout of \(timeout) seconds waiting for snapshot.

        This can happen when an asynchronously rendered view (like a web view) has not loaded. \
        Ensure that every subview of the view hierarchy has loaded to avoid timeouts, or, if a \
        timeout is unavoidable, consider setting the "timeout" parameter of "assertSnapshot" to \
        a higher value.
        """
      case .incorrectOrder, .invertedFulfillment, .interrupted:
        return "Couldn't snapshot value"
        @unknown default:
        return "Couldn't snapshot value"
      }

      guard var diffable = optionalDiffable else {
        return "Couldn't snapshot value"
      }

      guard !recording, fileManager.fileExists(atPath: snapshotFileUrl.path) else {
        try snapshotting.diffing.toData(diffable).write(to: snapshotFileUrl)
        return recording
          ? """
          Record mode is on. Turn record mode off and re-run "\(testName)" to test against the newly-recorded snapshot.

          open "\(snapshotFileUrl.path)"

          Recorded snapshot: …
          """
          : """
          No reference was found on disk. Automatically recorded snapshot: …

          open "\(snapshotFileUrl.path)"

          Re-run "\(testName)" to test against the newly-recorded snapshot.
          """
      }

      let data = try Data(contentsOf: snapshotFileUrl)
      let reference = snapshotting.diffing.fromData(data)

      #if os(iOS) || os(tvOS)
        // If the image generation fails for the diffable part use the reference
        if let localDiff = diffable as? UIImage, localDiff.size == .zero {
          diffable = reference
        }
      #endif

      guard let (failure, attachments) = snapshotting.diffing.diff(reference, diffable) else {
        return nil
      }

      let artifactsUrl = URL(
        fileURLWithPath: ProcessInfo.processInfo.environment["SNAPSHOT_ARTIFACTS"] ?? NSTemporaryDirectory(),
        isDirectory: true
      )
      let artifactsSubUrl = artifactsUrl.appendingPathComponent(name)
      try fileManager.createDirectory(at: artifactsSubUrl, withIntermediateDirectories: true)
      let failedSnapshotFileUrl = artifactsSubUrl.appendingPathComponent(snapshotFileUrl.lastPathComponent)
      try snapshotting.diffing.toData(diffable).write(to: failedSnapshotFileUrl)

      if !attachments.isEmpty {
        #if !os(Linux)
          if ProcessInfo.processInfo.environment.keys.contains("__XCODE_BUILT_PRODUCTS_DIR_PATHS") {
            XCTContext.runActivity(named: "Attached Failure Diff") { activity in
              attachments.forEach {
                activity.add($0)
              }
            }
          }
        #endif
      }

      let minus = "−"
      let plus = "+"
      let diffMessage = diffTool
        .map { "\($0) \"\(snapshotFileUrl.path)\" \"\(failedSnapshotFileUrl.path)\"" }
        ?? "@\(minus)\n\"\(snapshotFileUrl.path)\"\n@\(plus)\n\"\(failedSnapshotFileUrl.path)\""
      return """
      Snapshot does not match reference.

      \(diffMessage)

      \(failure.trimmingCharacters(in: .whitespacesAndNewlines))
      """
    } catch {
      return error.localizedDescription
    }
  }
}
