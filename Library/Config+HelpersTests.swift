@testable import KsApi
import Prelude
import XCTest

final class Config_HelpersTests: TestCase {

  func testIsEnabled_Control() {
    let config = Config.template
      |> \.abExperiments .~ [Experiment.Name.testExperiment.rawValue: "control"]

    withEnvironment(config: config) {
      XCTAssertFalse(Experiment.Name.testExperiment.isEnabled())
    }
  }

  func testIsEnabled_Experimental() {
    let config = Config.template
      |> \.abExperiments .~ [Experiment.Name.testExperiment.rawValue: "experimental"]

    withEnvironment(config: config) {
      XCTAssertTrue(Experiment.Name.testExperiment.isEnabled())
    }
  }
}
