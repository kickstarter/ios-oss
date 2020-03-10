import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class FeatureHelpersTests: TestCase {
  // MARK: - goRewardless

  func testFeatureGoRewardlessIsEnabled_isTrue() {
    let config = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: true]

    withEnvironment(config: config) {
      XCTAssertTrue(featureGoRewardlessIsEnabled())
    }
  }

  func testFeatureGoRewardlessIsEnabled_isFalse() {
    let config = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: false]

    withEnvironment(config: config) {
      XCTAssertFalse(featureGoRewardlessIsEnabled())
    }
  }

  func testFeatureGoRewardlessIsEnabled_isFalse_whenNil() {
    withEnvironment(config: .template) {
      XCTAssertFalse(featureGoRewardlessIsEnabled())
    }
  }

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
