import Library

internal struct MockOptimizelyError: Error {}

internal class MockOptimizelyClient: OptimizelyClientType {
  var experiments: [String: String] = [:]
  var error: MockOptimizelyError?

  internal func activate(experimentKey: String, userId _: String, attributes _: [String: Any?]?) throws
    -> String {
    if let error = self.error {
      throw error
    }

    guard let experimentVariant = self.experiments[experimentKey] else {
      return OptimizelyExperiment.Variant.control.rawValue
    }

    return experimentVariant
  }
}
