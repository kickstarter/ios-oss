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
    self.features = [:]
    self.getVariantPathCalled = false
  }

  public func isFeatureEnabled(featureKey: String, userId _: String, attributes _: [String: Any?]?) -> Bool {
    return self.features[featureKey] == true
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
