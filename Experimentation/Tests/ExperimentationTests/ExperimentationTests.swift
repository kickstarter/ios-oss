@testable import Experimentation
import Statsig
import XCTest

final class ExperimentationTests: XCTestCase {
  func testClient_returnsBoolValue() {
    let experiment = iOSTestExperiment()

    let expectation = XCTestExpectation(description: "Waiting for Statsig")
    
    Statsig.initialize(sdkKey: "", options: StatsigOptions(initializeOffline: true)) { _ in
      expectation.fulfill()
    }

    self.wait(for: [expectation])

    let client = StatsigClient(sdkKey: "")

    XCTAssertNil(client.boolValue(forKey: .experiment_parameter_one, inExperiment: experiment))

    Statsig.overrideConfig("ios_test_experiment", value: ["experiment_parameter_one": true])
    
    let foo = Statsig.getAllOverrides()

    XCTAssertEqual(client.boolValue(forKey: .experiment_parameter_one, inExperiment: experiment), true)
  }
}
