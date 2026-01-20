@testable import Library
import XCTest

final class EnvironmentVariablesTests: XCTestCase {
  func testTrackingVariable() {
    var processInfo = MockProcessInfo()
    XCTAssertFalse(EnvironmentVariables().isTrackingEnabled)

    processInfo = MockProcessInfo(environment: [VariableName.trackingEnabled.rawValue: "giberish"])
    XCTAssertFalse(EnvironmentVariables(processInfo: processInfo).isTrackingEnabled)

    processInfo = MockProcessInfo(environment: [VariableName.trackingEnabled.rawValue: "false"])
    XCTAssertFalse(EnvironmentVariables(processInfo: processInfo).isTrackingEnabled)

    processInfo = MockProcessInfo(environment: [VariableName.trackingEnabled.rawValue: "true"])
    XCTAssertTrue(EnvironmentVariables(processInfo: processInfo).isTrackingEnabled)
  }
}

private struct MockProcessInfo: ProcessInfoType {
  let environment: [String: String]

  internal init(environment: [String: String] = [:]) {
    self.environment = environment
  }
}
