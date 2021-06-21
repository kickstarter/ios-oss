import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class FeatureHelpersTests: TestCase {
  // MARK: - Braze

  func testFeatureBraze_isTrue() {
    let config = Config.template
      |> \.features .~ [Feature.braze.rawValue: true]

    withEnvironment(config: config) {
      XCTAssertTrue(featureBrazeIsEnabled())
    }
  }

  func testFeatureBraze_isFalse() {
    let config = Config.template
      |> \.features .~ [Feature.braze.rawValue: false]

    withEnvironment(config: config) {
      XCTAssertFalse(featureBrazeIsEnabled())
    }
  }

  func testFeatureBraze_isFalse_whenNil() {
    withEnvironment(config: .template) {
      XCTAssertFalse(featureBrazeIsEnabled())
    }
  }

  // MARK: - Segment

  func testFeatureSegment_isTrue() {
    let config = Config.template
      |> \.features .~ [Feature.segment.rawValue: true]

    withEnvironment(config: config) {
      XCTAssertTrue(featureSegmentIsEnabled())
    }
  }

  func testFeatureSegment_isFalse() {
    let config = Config.template
      |> \.features .~ [Feature.segment.rawValue: false]

    withEnvironment(config: config) {
      XCTAssertFalse(featureSegmentIsEnabled())
    }
  }

  func testFeatureSegment_isFalse_whenNil() {
    withEnvironment(config: .template) {
      XCTAssertFalse(featureSegmentIsEnabled())
    }
  }
}
