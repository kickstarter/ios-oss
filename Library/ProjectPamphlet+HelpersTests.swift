import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ProjectPamphlet_HelpersTests: TestCase {
  private let releaseBundle = MockBundle(bundleIdentifier: KickstarterBundleIdentifier.release.rawValue,
                                         lang: "en")

  func testUserCanSeeNativeCheckout_featureNativeCheckoutEnabled_experimentNativeCheckoutEnabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]

    withEnvironment(config: config, mainBundle: releaseBundle) {
      XCTAssertTrue(userCanSeeNativeCheckout())
    }
  }

  func testUserCanSeeNativeCheckout_featureNativeCheckoutEnabled_experimentNativeCheckoutDisabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]

    withEnvironment(config: config, mainBundle: releaseBundle) {
      XCTAssertFalse(userCanSeeNativeCheckout())
    }
  }

  func testUserCanSeeNativeCheckout_featureNativeCheckoutDisabled_experimentNativeCheckoutEnabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: false]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "experimental"]

    withEnvironment(config: config, mainBundle: releaseBundle) {
      XCTAssertFalse(userCanSeeNativeCheckout())
    }
  }

  func testUserCanSeeNativeCheckout_featureNativeCheckoutDisabled_experimentNativeCheckoutDisabled() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: false]
      |> \.abExperiments .~ [Experiment.Name.nativeCheckoutV1.rawValue: "control"]

    withEnvironment(config: config, mainBundle: releaseBundle) {
      XCTAssertFalse(userCanSeeNativeCheckout())
    }
  }
}
