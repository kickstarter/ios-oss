@testable import Library
import XCTest

final class EnvironmentVariablesTests: XCTestCase {
  func testKoalaTrackingVariable() {
    var processInfo = MockProcessInfo()
    XCTAssertFalse(EnvironmentVariables().isKoalaTrackingEnabled)

    processInfo = MockProcessInfo(environment: [VariableName.koalaTracking.rawValue: "giberish"])
    XCTAssertFalse(EnvironmentVariables(processInfo: processInfo).isKoalaTrackingEnabled)

    processInfo = MockProcessInfo(environment: [VariableName.koalaTracking.rawValue: "false"])
    XCTAssertFalse(EnvironmentVariables(processInfo: processInfo).isKoalaTrackingEnabled)

    processInfo = MockProcessInfo(environment: [VariableName.koalaTracking.rawValue: "true"])
    XCTAssertTrue(EnvironmentVariables(processInfo: processInfo).isKoalaTrackingEnabled)
  }
}

private struct MockProcessInfo: ProcessInfoType {
  let environment: [String: String]

  internal init(environment: [String: String] = [:]) {
    self.environment = environment
  }
}
