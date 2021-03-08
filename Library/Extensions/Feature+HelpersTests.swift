import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class FeatureHelpersTests: TestCase {
  // MARK: - Email Verification Flow

  func testFeatureEmailVerificationFlow_isTrue() {
    let config = Config.template
      |> \.features .~ [Feature.emailVerificationFlow.rawValue: true]

    withEnvironment(config: config) {
      XCTAssertTrue(featureEmailVerificationFlowIsEnabled())
    }
  }

  func testFeatureEmailVerificationFlow_isFalse() {
    let config = Config.template
      |> \.features .~ [Feature.emailVerificationFlow.rawValue: false]

    withEnvironment(config: config) {
      XCTAssertFalse(featureEmailVerificationFlowIsEnabled())
    }
  }

  func testFeatureEmailVerificationFlow_isFalse_whenNil() {
    withEnvironment(config: .template) {
      XCTAssertFalse(featureEmailVerificationFlowIsEnabled())
    }
  }

  // MARK: - Email Verification Skip

  func testFeatureEmailVerificationSkip_isTrue() {
    let config = Config.template
      |> \.features .~ [Feature.emailVerificationSkip.rawValue: true]

    withEnvironment(config: config) {
      XCTAssertTrue(featureEmailVerificationSkipIsEnabled())
    }
  }

  func testFeatureEmailVerificationSkip_isFalse() {
    let config = Config.template
      |> \.features .~ [Feature.emailVerificationSkip.rawValue: false]

    withEnvironment(config: config) {
      XCTAssertFalse(featureEmailVerificationSkipIsEnabled())
    }
  }

  func testFeatureEmailVerificationSkip_isFalse_whenNil() {
    withEnvironment(config: .template) {
      XCTAssertFalse(featureEmailVerificationSkipIsEnabled())
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
