public enum MockOptimizelyError: Error {
  case generic

  var localizedDescription: String {
    return "Optimizely Error"
  }
}

public class MockOptimizelyClient: OptimizelyClientType {
  // MARK: - Experiment Activation Test Properties

  public var activatePathCalled: Bool
  public var allKnownExperiments: [String]
  public var experiments: [String: String]
  public var features: [String: Bool]
  public var getVariantPathCalled: Bool
  public var error: MockOptimizelyError?
  public var userAttributes: [String: Any?]?

  // MARK: - Event Tracking Test Properties

  public var trackedAttributes: [String: Any?]?
  public var trackedEventKey: String?
  public var trackedUserId: String?

  public init() {
    self.activatePathCalled = false
    self.allKnownExperiments = []
    self.experiments = [:]
    self.features = [:]
    self.getVariantPathCalled = false
  }

  public func activate(experimentKey: String, userId: String, attributes: [String: Any?]?) throws
    -> String {
      self.activatePathCalled = true

      return try self.experiment(forKey: experimentKey, userId: userId, attributes: attributes)
    }

  public func getVariationKey(experimentKey: String, userId: String, attributes: [String: Any?]?) throws
    -> String {
      self.getVariantPathCalled = true
      return try self.experiment(forKey: experimentKey, userId: userId, attributes: attributes)
    }

  public func isFeatureEnabled(featureKey: String, userId _: String, attributes _: [String: Any?]?) -> Bool {
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

  public func track(
    eventKey: String,
    userId: String,
    attributes: [String: Any?]?,
    eventTags _: [String: Any]?
  ) throws {
    self.trackedEventKey = eventKey
    self.trackedAttributes = attributes
    self.trackedUserId = userId
  }

  public func allExperiments() -> [String] {
    return self.allKnownExperiments
  }
}
