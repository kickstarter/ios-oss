import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class FeatureHelpersTests: TestCase {
  // MARK: - nativeCheckout

  func testFeatureNativeCheckoutIsEnabled_isTrue() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]

    withEnvironment(config: config) {
      XCTAssertTrue(featureNativeCheckoutIsEnabled())
    }
  }

  func testFeatureNativeCheckoutIsEnabled_isFalse() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: false]

    withEnvironment(config: config) {
      XCTAssertFalse(featureNativeCheckoutIsEnabled())
    }
  }

  func testFeatureNativeCheckoutIsEnabled_isFalse_whenNil() {
    withEnvironment(config: .template) {
      XCTAssertFalse(featureNativeCheckoutIsEnabled())
    }
  }

  // MARK: - nativeCheckoutPledgeView

  func testFeatureNativeCheckoutPledgeViewEnabled_isTrue() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckoutPledgeView.rawValue: true]

    withEnvironment(config: config) {
      XCTAssertTrue(featureNativeCheckoutPledgeViewIsEnabled())
    }
  }

  func testFeatureNativeCheckoutPledgeViewEnabled_isFalse() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckoutPledgeView.rawValue: false]

    withEnvironment(config: config) {
      XCTAssertFalse(featureNativeCheckoutPledgeViewIsEnabled())
    }
  }

  func testFeatureNativeCheckoutPledgeViewEnabled_isFalse_whenNil() {
    withEnvironment(config: .template) {
      XCTAssertFalse(featureNativeCheckoutPledgeViewIsEnabled())
    }
  }
}
