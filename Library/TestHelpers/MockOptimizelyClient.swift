import Library
import XCTest

internal struct MockOptimizelyError: Error {}

internal class MockOptimizelyClient: OptimizelyClientType {
  // MARK: - Experiment Activation Test Properties

  var activatePathCalled: Bool = false
  var experiments: [String: String] = [:]
  var error: MockOptimizelyError?
  var getVariantPathCalled: Bool = false
  var userAttributes: [String: Any?]?

  // MARK: - Event Tracking Test Properties

  var trackedAttributes: [String: Any?]?
  var trackedEventKey: String?
  var trackedEventTags: [String: Any?]?
  var trackedUserId: String?

  internal func activate(experimentKey: String, userId: String, attributes: [String: Any?]?) throws
    -> String {
    self.activatePathCalled = true
    return try self.experiment(forKey: experimentKey, userId: userId, attributes: attributes)
  }

  internal func getVariationKey(experimentKey: String, userId: String, attributes: [String: Any?]?) throws
    -> String {
    self.getVariantPathCalled = true
    return try self.experiment(forKey: experimentKey, userId: userId, attributes: attributes)
  }

  private func experiment(forKey key: String, userId _: String, attributes: [String: Any?]?) throws
    -> String {
    self.userAttributes = attributes

    if let error = self.error {
      throw error
    }

    guard let experimentVariant = self.experiments[key] else {
      return OptimizelyExperiment.Variant.control.rawValue
    }

    return experimentVariant
  }

  func track(eventKey: String, userId: String, attributes: [String: Any?]?, eventTags: [String: Any]?)
    throws {
    self.trackedEventKey = eventKey
    self.trackedAttributes = attributes
    self.trackedEventTags = eventTags
    self.trackedUserId = userId
  }
}

extension TestCase {
  func assertBaseUserAttributesLoggedOut() {
    XCTAssertEqual(
      self.optimizelyClient.trackedAttributes?["session_os_version"] as? String,
      "MockSystemVersion"
    )
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_user_is_logged_in"] as? Bool, false)
    XCTAssertEqual(
      self.optimizelyClient.trackedAttributes?["session_app_release_version"] as? String,
      "1.2.3.4.5.6.7.8.9.0"
    )
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_apple_pay_device"] as? Bool, true)
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_device_format"] as? String, "phone")

    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_country"] as? String, "us")
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_display_language"] as? String, "en")

    XCTAssertNil(self.optimizelyClient.trackedAttributes?["session_ref_tag"] as? String)
    XCTAssertNil(self.optimizelyClient.trackedAttributes?["session_referrer_credit"] as? String)
    XCTAssertNil(self.optimizelyClient.trackedAttributes?["user_backed_projects_count"] as? Int)
    XCTAssertNil(self.optimizelyClient.trackedAttributes?["user_launched_projects_count"] as? Int)
    XCTAssertNil(self.optimizelyClient.trackedAttributes?["user_facebook_account"] as? Bool)
  }
}
