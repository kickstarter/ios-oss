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
}
