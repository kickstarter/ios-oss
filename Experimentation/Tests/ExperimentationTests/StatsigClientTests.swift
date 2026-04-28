@testable import Experimentation
import Statsig
import XCTest

final class StatsigClientTests: XCTestCase {
  override func setUp() {
    let expectation = XCTestExpectation(description: "Waiting for Statsig")

    // Statsig uses a singleton, so fake-initializing it first.
    Statsig.initialize(sdkKey: "fake", options: StatsigOptions(initializeOffline: true)) { _ in
      expectation.fulfill()
    }

    self.wait(for: [expectation])

    Statsig.removeAllOverrides()
  }

  func testClient_returnsBoolValue_forExperiment() {
    let experiment = iOSTestExperiment()

    let client = StatsigClient(sdkKey: "")

    XCTAssertNil(client.boolValue(forKey: .experiment_parameter_one, inExperiment: experiment))

    Statsig.overrideConfig("ios_test_experiment", value: ["experiment_parameter_one": true])

    XCTAssertEqual(client.boolValue(forKey: .experiment_parameter_one, inExperiment: experiment), true)
  }

  func testClient_returnsBoolValue_forFeatureGate() {
    let client = StatsigClient(sdkKey: "")

    XCTAssertFalse(client.checkGate(for: .videoFeed))

    Statsig.overrideGate("video_feed", value: true)

    XCTAssertTrue(client.checkGate(for: .videoFeed))
  }
}
