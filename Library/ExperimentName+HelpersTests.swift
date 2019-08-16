@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ExperimentName_HelpersTests: TestCase {
  // MARK: nativeCheckout
  func testExperimentNativeCheckoutIsEnabled_Control() {

    let config = Config.template
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]

    withEnvironment(config: config) {
      XCTAssertFalse(experimentNativeCheckoutIsEnabled())
    }
  }

  func testExperimentNativeCheckoutIsEnabled_Experimental() {
    let config = Config.template
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]

    withEnvironment(config: config) {
      XCTAssertTrue(experimentNativeCheckoutIsEnabled())
    }
  }

  func testExperimentNativeCheckoutIsEnabled_NoExperiments() {
    let config = Config.template
      |> \.abExperiments .~ [:]

    withEnvironment(config: config) {
      XCTAssertFalse(experimentNativeCheckoutIsEnabled())
    }
  }

  func testExperimentNativeCheckoutIsEnabled_UnknownExperiment() {
    let config = Config.template
      |> \.abExperiments .~ ["unknown": "experimental"]

    withEnvironment(config: config) {
      XCTAssertFalse(experimentNativeCheckoutIsEnabled())
    }
  }
}
