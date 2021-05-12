import Library
import XCTest

internal enum MockOptimizelyError: Error {
  case generic

  var localizedDescription: String {
    return "Optimizely Error"
  }
}

internal class MockOptimizelyClient: OptimizelyClientType {
  // MARK: - Experiment Activation Test Properties

  var activatePathCalled: Bool = false
  var allKnownExperiments: [String] = []
  var experiments: [String: String] = [:]
  var error: MockOptimizelyError?
  var features: [String: Bool] = [:]
  var getVariantPathCalled: Bool = false
  var userAttributes: [String: Any?]?

  // MARK: - Event Tracking Test Properties

  var trackedAttributes: [String: Any?]?
  var trackedEventKey: String?
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

  func isFeatureEnabled(featureKey: String, userId _: String, attributes _: [String: Any?]?) -> Bool {
    return self.features[featureKey] == true
  }

  private func experiment(forKey key: String, userId _: String, attributes: [String: Any?]?) throws
    -> String {
      self.userAttributes = attributes

      if let error = self.error {
        throw error
      }

      guard let experimentVariant = self.experiments[key] else {
        throw MockOptimizelyError.generic
      }

      return experimentVariant
    }

  func track(
    eventKey: String,
    userId: String,
    attributes: [String: Any?]?,
    eventTags _: [String: Any]?
  ) throws {
    self.trackedEventKey = eventKey
    self.trackedAttributes = attributes
    self.trackedUserId = userId
  }

  func allExperiments() -> [String] {
    return self.allKnownExperiments
  }
}
