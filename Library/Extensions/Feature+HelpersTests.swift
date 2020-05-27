import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class FeatureHelpersTests: TestCase {
  // MARK: - Qualtrics

  func testFeatureQualtrics_isTrue() {
    let config = Config.template
      |> \.features .~ [Feature.qualtrics.rawValue: true]

    withEnvironment(config: config) {
      XCTAssertTrue(featureQualtricsIsEnabled())
    }
  }

  func testFeatureQualtrics_isFalse() {
    let config = Config.template
      |> \.features .~ [Feature.qualtrics.rawValue: false]

    withEnvironment(config: config) {
      XCTAssertFalse(featureQualtricsIsEnabled())
    }
  }

  func testFeatureQualtrics_isFalse_whenNil() {
    withEnvironment(config: .template) {
      XCTAssertFalse(featureQualtricsIsEnabled())
    }
  }
}
