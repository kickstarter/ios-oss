import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ProjectPamphlet_HelpersTests: TestCase {
  func testUserCanSeeNativeCheckout_featureNativeCheckoutEnabled_checkoutExperimentEnabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]

    withEnvironment(config: config) {
      XCTAssertTrue(userCanSeeNativeCheckout())
    }
  }

  func testUserCanSeeNativeCheckout_featureNativeCheckoutEnabled_checkoutExperimentDisabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]

    withEnvironment(config: config) {
      XCTAssertFalse(userCanSeeNativeCheckout())
    }
  }

  func testUserCanSeeNativeCheckout_featureNativeCheckoutDisabled_checkoutExperimentEnabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: false]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]

    withEnvironment(config: config) {
      XCTAssertFalse(userCanSeeNativeCheckout())
    }
  }

  func testUserCanSeeNativeCheckout_featureNativeCheckoutDisabled_checkoutExperimentDisabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: false]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]

    withEnvironment(config: config) {
      XCTAssertFalse(userCanSeeNativeCheckout())
    }
  }
}
