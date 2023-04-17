public enum MockOptimizelyError: Error {
  case generic

  var localizedDescription: String {
    return "Optimizely Error"
  }
}

public class MockOptimizelyClient: OptimizelyClientType {
  public var features: [String: Bool]
  public var error: MockOptimizelyError?
  public var userAttributes: [String: Any?]?

  // MARK: - Event Tracking Test Properties

  public var trackedAttributes: [String: Any?]?
  public var trackedEventKey: String?
  public var trackedUserId: String?

  public init() {
    self.features = [:]
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
}
