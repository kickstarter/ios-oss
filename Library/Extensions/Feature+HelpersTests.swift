import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class FeatureHelpersTests: TestCase {
  func testFeatureNativeCheckoutEnabled_isTrue() {
    let config = Config.template
      |> \.features .~ [Feature.checkout.rawValue: true]

    withEnvironment(config: config) {
      XCTAssertTrue(featureNativeCheckoutEnabled())
    }
  }

  func testFeatureNativeCheckoutEnabled_isFalse() {
    let config = Config.template
      |> \.features .~ [Feature.checkout.rawValue: false]

    withEnvironment(config: config) {
      XCTAssertFalse(featureNativeCheckoutEnabled())
    }
  }

  func testFeatureNativeCheckoutEnabled_isFalse_whenNil() {
    withEnvironment(config: .template) {
      XCTAssertFalse(featureNativeCheckoutEnabled())
    }
  }
}
