import Library

internal struct MockOptimizelyError: Error {}

internal class MockOptimizelyClient: OptimizelyClientType {
  var activatePathCalled: Bool = false
  var experiments: [String: String] = [:]
  var error: MockOptimizelyError?
  var getVariantPathCalled: Bool = false

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

  private func experiment(forKey key: String, userId _: String, attributes _: [String: Any?]?) throws
    -> String {
    if let error = self.error {
      throw error
    }

    guard let experimentVariant = self.experiments[key] else {
      return OptimizelyExperiment.Variant.control.rawValue
    }

    return experimentVariant
  }
}
