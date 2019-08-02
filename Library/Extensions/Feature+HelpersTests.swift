import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class FeatureHelpersTests: TestCase {
  // MARK: - nativeCheckout

  func testFeatureNativeCheckoutEnabled_isTrue() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]

    withEnvironment(config: config) {
      XCTAssertTrue(featureNativeCheckoutEnabled())
    }
  }

  func testFeatureNativeCheckoutEnabled_isFalse() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: false]

    withEnvironment(config: config) {
      XCTAssertFalse(featureNativeCheckoutEnabled())
    }
  }

  func testFeatureNativeCheckoutEnabled_isFalse_whenNil() {
    withEnvironment(config: .template) {
      XCTAssertFalse(featureNativeCheckoutEnabled())
    }
  }

  // MARK: - nativeCheckoutPledgeView

  func testFeatureNativeCheckoutPledgeViewEnabled_isTrue() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckoutPledgeView.rawValue: true]

    withEnvironment(config: config) {
      XCTAssertTrue(featureNativeCheckoutPledgeViewEnabled())
    }
  }

  func testFeatureNativeCheckoutPledgeViewEnabled_isFalse() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckoutPledgeView.rawValue: false]

    withEnvironment(config: config) {
      XCTAssertFalse(featureNativeCheckoutPledgeViewEnabled())
    }
  }

  func testFeatureNativeCheckoutPledgeViewEnabled_isFalse_whenNil() {
    withEnvironment(config: .template) {
      XCTAssertFalse(featureNativeCheckoutPledgeViewEnabled())
    }
  }
}
