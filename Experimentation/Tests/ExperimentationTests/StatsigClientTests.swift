@testable import Experimentation
import Statsig
import XCTest

final class StatsigWrapperTests: XCTestCase {
  override func tearDown() {
    let expectation = XCTestExpectation(description: "Waiting for Statsig")

    let statsig = StatsigClient(sdkKey: "fake", options: StatsigOptions(initializeOffline: true)) { _ in
      expectation.fulfill()
    }

    self.wait(for: [expectation])

    // The overrides use an internal store (not linked to an individual `StatsigClient`) and are stateful.
    // Clean them up to prevent flaky tests.
    statsig.removeAllOverrides()
  }

  func testClient_returnsBoolValue_forExperiment() {
    let experiment = iOSTestExperiment()
    let expectation = XCTestExpectation(description: "Waiting for Statsig")

    let statsig = StatsigClient(sdkKey: "fake", options: StatsigOptions(initializeOffline: true)) { _ in
      expectation.fulfill()
    }

    let client = StatsigWrapper(client: statsig)

    XCTAssertNil(
      client.boolValue(forKey: .experiment_parameter_one, inExperiment: experiment),
      "Value should be nil because Statsig isn't initialized yet."
    )
    XCTAssertNil(
      client.boolValue(forKey: .experiment_parameter_two, inExperiment: experiment),
      "Value should be nil because Statsig isn't initialized yet."
    )

    self.wait(for: [expectation])

    XCTAssertNil(
      client.boolValue(forKey: .experiment_parameter_one, inExperiment: experiment),
      "Value should be nil because experiment has no value."
    )
    XCTAssertNil(
      client.boolValue(forKey: .experiment_parameter_two, inExperiment: experiment),
      "Value should be nil because Statsig isn't initialized yet."
    )

    statsig.overrideConfig(
      "ios_test_experiment",
      value: [
        "experiment_parameter_one": true,
        "experiment_parameter_two": false
      ]
    )

    XCTAssertEqual(client.boolValue(forKey: .experiment_parameter_one, inExperiment: experiment), true)
    XCTAssertEqual(client.boolValue(forKey: .experiment_parameter_two, inExperiment: experiment), false)
  }

  func testClient_returnsBoolValue_forFeatureGate() {
    let expectation = XCTestExpectation(description: "Waiting for Statsig")
    let statsig = StatsigClient(sdkKey: "fake", options: StatsigOptions(initializeOffline: true)) { _ in
      expectation.fulfill()
    }

    let client = StatsigWrapper(client: statsig)

    XCTAssertNil(
      client.checkGate(for: .videoFeed),
      "Gate should be nil because Statsig isn't initialized yet."
    )

    self.wait(for: [expectation])

    XCTAssertEqual(
      client.checkGate(for: .videoFeed),
      false,
      "Gate should be false because gate has no value."
    )

    statsig.overrideGate("video_feed", value: true)

    XCTAssertEqual(client.checkGate(for: .videoFeed), true)

    statsig.overrideGate("video_feed", value: false)

    XCTAssertEqual(client.checkGate(for: .videoFeed), false)
  }
}
