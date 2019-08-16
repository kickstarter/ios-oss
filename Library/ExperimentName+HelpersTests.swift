@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ExperimentName_HelpersTests: TestCase {
  // MARK: nativeCheckout
  func testNativeCheckoutExperimentIsEnabled() {

    let config = Config.template
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]

    withEnvironment(config: config) {
      XCTAssertFalse(nativeCheckoutExperimentIsEnabled())
    }
  }

  func testIsEnabled_Experimental() {
    let config = Config.template
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]

    withEnvironment(config: config) {
      XCTAssertTrue(nativeCheckoutExperimentIsEnabled())
    }
  }
}
